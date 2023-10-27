<?php

namespace Database\Seeders;

use Anomaly\FilesModule\Disk\Contract\DiskRepositoryInterface;
use Anomaly\FilesModule\Folder\Contract\FolderRepositoryInterface;
use Anomaly\UsersModule\Role\Contract\RoleRepositoryInterface;
use Anomaly\UsersModule\User\Contract\UserRepositoryInterface;
use Anomaly\UsersModule\User\UserActivator;
use Illuminate\Console\Command;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Console\Input\ArgvInput;
use Visiosoft\AdvsModule\Adv\Command\DeleteInstaller;

class DatabaseSeeder extends Seeder
{
    protected $users;
    protected $roles;
    protected $activator;
    protected $disks;
    protected $folders;
    protected $command;

    public function __construct(
        UserRepositoryInterface $users,
        DiskRepositoryInterface $disks,
        FolderRepositoryInterface $folders,
        RoleRepositoryInterface $roles,
        UserActivator $activator,
        Command $command
    )
    {
        $this->users = $users;
        $this->roles = $roles;
        $this->activator = $activator;
        $this->disks = $disks;
        $this->folders = $folders;
        $this->command = $command;
    }

    public function run()
    {

        $admin = $this->roles->findBySlug('admin');

        $this->users->unguard();
        $this->users->newQuery()->where('email', "info@openclassify.com")->forceDelete();
        $visiosoft_administrator = $this->users->create(
            [
                'first_name' => 'Dev',
                'last_name' => 'Openclassify',
                'display_name' => 'openclassify',
                'email' => "info@openclassify.com",
                'username' => "openclassify",
                'password' => "openclassify",
            ]
        );


        $visiosoft_administrator->roles()->sync([$admin->getId()]);

        $this->activator->force($visiosoft_administrator);

        //Create Category Icon Folder
        if (is_null($this->folders->findBy('slug', 'category_icon'))) {
            $disk = $this->disks->findBySlug('local');

            $this->folders->create([
                'en' => [
                    'name' => 'Category Icon',
                    'description' => 'A folder for Category Icon.',
                ],
                'slug' => 'category_icon',
                'disk' => $disk,
            ]);
        }
        $application_reference = (new ArgvInput())->getParameterOption('--app', env('APPLICATION_REFERENCE', 'default'));
        $settings = str_replace('{application_reference}', $application_reference,
            file_get_contents(realpath(dirname(__DIR__)) . '/seeders/settings.sql'));
        Model::unguard();
        DB::unprepared($settings);
        Model::reguard();

        //Delete Installer
        dispatch_now(new DeleteInstaller());

        if (is_null($this->folders->findBy('slug', 'ads_excel'))) {
            $disk = $this->disks->findBySlug('local');

            $this->folders->create([
                'en' => [
                    'name' => 'Ads Excel',
                    'description' => 'A folder for Ads Excel.',
                ],
                'slug' => 'ads_excel',
                'disk' => $disk,
            ]);
        }


        if ($images_folder = $this->folders->findBySlug('images')) {
            $images_folder->update([
                'allowed_types' => [
                    'jpg', 'jpeg', 'png'
                ],
            ]);
        }


        //Favicon Folder
        if (is_null($this->folders->findBy('slug', 'favicon'))) {
            $disk = $this->disks->findBySlug('local');

            $this->folders->create([
                'en' => [
                    'name' => 'Favicon',
                    'description' => 'A folder for Favicon.',
                ],
                'slug' => 'favicon',
                'disk' => $disk,
                'allowed_types' => [
                    'ico', 'png',
                ],
            ]);
        }


    }
}
