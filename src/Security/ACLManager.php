<?php

namespace App\Security;

use App\Entity\User;
use Symfony\Component\Security\Core\Security;

class ACLManager
{
    private Security $security;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    public function isAdmin()
    {
        return $this->security->isGranted(User::ROLE_ADMIN);
    }

}