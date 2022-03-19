<?php

namespace App\Service;

use App\Entity\Export;
use App\Entity\User;
use DateTime;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Serializer\Serializer;

class Exporter
{
    private const USER = '-users-';

    private EntityManagerInterface $em;
    private Serializer $serializer;
    private Filesystem $filesystem;
    private $exportDirectory;

    public function __construct(EntityManagerInterface $em, ContainerInterface $container, Filesystem $filesystem, $exportDirectory)
    {
        $this->em = $em;
        $this->serializer = $container->get('serializer');
        $this->filesystem = $filesystem;
        $this->exportDirectory = $exportDirectory . DIRECTORY_SEPARATOR;
    }

    public function exportUsersOlderThan(DateTime $date, int $ownerId)
    {
        $owner = $this->em->getRepository(User::class)->find($ownerId);
        $users = $this->em->getRepository(User::class)->findOlderThan($date);
        $content = $this->serializer->encode($users, 'csv');
        $filename = $this->exportDirectory . $date->getTimestamp() . self::USER . uniqid(self::USER, true) . ".csv";
        $export = (new Export())
            ->setFilename($filename)
            ->setUser($owner);
        $this->saveFile($filename, $content);
        $this->em->getRepository(Export::class)->add($export);
    }

    private function saveFile(string $filename, $content)
    {
        $filename = $this->exportDirectory . $filename;
//        if (!$this->filesystem->exists($filename)) {
//            $this->filesystem->touch($filename);
//        }
        $this->filesystem->dumpFile($filename, $content);
    }

}