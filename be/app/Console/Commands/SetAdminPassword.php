<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use App\Models\Admin;

class SetAdminPassword extends Command
{
    protected $signature = 'admin:set-password';
    protected $description = 'Cập nhật lại mật khẩu admin với Bcrypt';

    public function handle()
    {
        $admin = \App\Models\Admin::find(1);

        if ($admin) {
            $admin->password = Hash::make('12345');
            $admin->save();

            $this->info(' Đã cập nhật mật khẩu cho admin ID 1 thành công!');
        } else {
            $this->error(' Không tìm thấy admin ID 1');
        }
    }
}
