<?php

namespace App\Controller;

use App\Entity\User;
use App\Form\ExportRequestType;
use App\Messenger\Message\ExportMessage;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Annotation\Route;

class ExportController extends AbstractController
{
    /**
     * @Route("/export", name="app_export")
     */
    public function exportAction(Request $request, MessageBusInterface $messageBus): Response
    {
        $form = $this->createForm(ExportRequestType::class);
        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            $data = $form->getData();
            /** @var User $user */
            $user = $this->getUser();
            $exportMessage = new ExportMessage($user->getCreatedAt(), $user->getId(), $data['email']);
            $messageBus->dispatch($exportMessage);
            $this->redirectToRoute('app_home');
        }
        return $this->render('export/export.html.twig', [
            'controller_name' => 'ExportController',
            'form' => $form->createView()
        ]);
    }
}
