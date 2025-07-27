<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ContactReplyMail extends Mailable
{
    use Queueable, SerializesModels;

    public $replyContent;
    public $contact;

    public function __construct($contact, $replyContent)
    {
        $this->contact = $contact;
        $this->replyContent = $replyContent;
    }

    public function build()
    {
        return $this->subject('Phản hồi từ Khách sạn Ocean')
                    ->view('emails.contact_reply')  // tạo file blade này
                    ->with([
                        'name' => $this->contact->name,
                        'message' => $this->replyContent,
                    ]);
    }
}

