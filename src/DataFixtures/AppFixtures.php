<?php

namespace App\DataFixtures;

use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AppFixtures extends Fixture
{
    /**
     * @var UserPasswordHasherInterface
     */
    private $passwordHasher;

    public function __construct(UserPasswordHasherInterface $passwordHasher)
    {
        $this->passwordHasher = $passwordHasher;
    }

    public function load(ObjectManager $manager): void
    {
        $users = [
            ['email' => 'admin@admin.com', 'password' => 'admin', 'roles' => [User::ROLE_ADMIN]],
            ['email' => 'user@user.com', 'password' => 'user', 'roles' => [User::ROLE_USER]],
        ];

        foreach ($users as $user) {
            $newUser = (new User())
                ->setEmail($user['email'])
                ->setPlainPassword($user['password'])
                ->setRoles($user['roles']);
            $hashedPwd = $this->passwordHasher->hashPassword($newUser, $newUser->getPlainPassword());
            $newUser->setPassword($hashedPwd)
                ->eraseCredentials();

            $manager->getRepository(User::class)->add($newUser);
        }
    }


}
