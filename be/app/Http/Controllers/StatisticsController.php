<?php

namespace App\Http\Controllers;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\Booking;
use App\Models\Contact;
use App\Models\Message;
use Illuminate\Support\Facades\Log;

class StatisticsController extends Controller
{
    private function exportExcelResponse($spreadsheet, $filename,)
    {
        $writer = new Xlsx($spreadsheet);
        $temp_file = tempnam(sys_get_temp_dir(), $filename);
        $writer->save($temp_file);

        return response()->download($temp_file, $filename)->deleteFileAfterSend(true);
    }

    private function applyDateFilters($query, $request, $column = 'created_at') {
        if ($request->has('from') && $request->has('to')) {
            $query->whereBetween($column, [$request->from, $request->to]);
        }
    }

    public function exportRevenueExcel(Request $request)
    {
        Log::info('Filters:', $request->all());
        $query = Payment::withTrashed(); // bao gồm cả đã xoá mềm

        $this->applyDateFilters($query, $request, 'payment_date');

        if ($request->has('date')) {
            $query->whereDate('payment_date', $request->date);
        } elseif ($request->has('month')) {
            $query->whereMonth('payment_date', $request->month);
        } elseif ($request->has('year')) {
            $query->whereYear('payment_date', $request->year);
        }

        $payments = $query->get();

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->fromArray(
            ['ID', 'Booking ID', 'Amount', 'Method', 'Payment Date', 'Status', 'MoMo Order ID'],
            null, 'A1'
        );

        foreach ($payments as $i => $payment) {
            $sheet->fromArray([
                $payment->id,
                $payment->booking_id,
                $payment->amount,
                $payment->method,
                $payment->payment_date,
                $payment->status,
                $payment->momo_order_id,
            ], null, 'A' . ($i + 2));
        }

        return $this->exportExcelResponse($spreadsheet, 'revenue_report.xlsx');
    }

    public function exportBookingExcel(Request $request)
    {
        $query = Booking::with(['serviceOrders.service'])->withTrashed();

        $this->applyDateFilters($query, $request, 'check_in');

        if ($request->has('date')) {
            $query->whereDate('check_in', $request->date);
        } elseif ($request->has('month')) {
            $query->whereMonth('check_in', $request->month);
        } elseif ($request->has('year')) {
            $query->whereYear('check_in', $request->year);
        }

        $bookings = $query->get();

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->fromArray(
            ['ID', 'User ID', 'Room ID', 'Check In', 'Check Out', 'Total Price', 'Status', 'Discount Code', 'Created At', 'Services Used'],
            null, 'A1'
        );

        foreach ($bookings as $i => $booking) {
            $services = $booking->serviceOrders->pluck('service.name')->implode(', ');
            $sheet->fromArray([
                $booking->id,
                $booking->user_id,
                $booking->room_id,
                $booking->check_in,
                $booking->check_out,
                $booking->total_price,
                $booking->status,
                $booking->discount_code,
                $booking->created_at,
                $services
            ], null, 'A' . ($i + 2));
        }

        return $this->exportExcelResponse($spreadsheet, 'booking_report.xlsx');
    }

    public function exportFeedbackExcel(Request $request)
    {
        // Lấy cả soft-deleted
        $contacts = Contact::withTrashed();
        $messages = Message::withTrashed();

        $this->applyDateFilters($contacts, $request, 'created_at');
        $this->applyDateFilters($messages, $request, 'created_at');

        if ($request->has('date')) {
            $contacts->whereDate('created_at', $request->date);
            $messages->whereDate('created_at', $request->date);
        } elseif ($request->has('month')) {
            $contacts->whereMonth('created_at', $request->month);
            $messages->whereMonth('created_at', $request->month);
        } elseif ($request->has('year')) {
            $contacts->whereYear('created_at', $request->year);
            $messages->whereYear('created_at', $request->year);
        }

        $contacts = $contacts->get();
        $messages = $messages->get();

        $spreadsheet = new Spreadsheet();

        // ===== Sheet 1: Contact =====
        $contactSheet = $spreadsheet->getActiveSheet();
        $contactSheet->setTitle('Contacts');
        $contactSheet->fromArray(['ID', 'Name', 'Email', 'Phone', 'Subject', 'Message', 'Replied', 'Created At'], null, 'A1');

        $row = 2;
        foreach ($contacts as $contact) {
            $contactSheet->fromArray([
                $contact->id,
                $contact->name,
                $contact->email,
                $contact->phone,
                $contact->subject,
                $contact->message,
                $contact->replied ? 'Yes' : 'No',
                $contact->created_at,
            ], null, 'A' . $row);
            $row++;
        }

        // ===== Sheet 2: Messages =====
        $messageSheet = $spreadsheet->createSheet();
        $messageSheet->setTitle('Messages');
        $messageSheet->fromArray(['ID', 'Conversation ID', 'Sender', 'Message', 'Timestamp'], null, 'A1');

        $row = 2;
        foreach ($messages as $message) {
            $messageSheet->fromArray([
                $message->id,
                $message->conversation_id,
                $message->sender,
                $message->message,
                $message->created_at,
            ], null, 'A' . $row);
            $row++;
        }

        return $this->exportExcelResponse($spreadsheet, 'feedback_report.xlsx');
    }
}
