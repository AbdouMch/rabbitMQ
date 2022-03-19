<?php

namespace App\Controller;

use App\Security\ACLManager;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HomeController extends AbstractController
{
    /**
     * @Route("/home", name="app_home")
     */
    public function index(ACLManager $aclManager): Response
    {
        return $this->render('home/home.html.twig', [
            'isAdmin' => $aclManager->isAdmin(),
        ]);
    }
}
