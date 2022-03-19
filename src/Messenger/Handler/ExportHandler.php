<?php

namespace App\Messenger\Handler;

use App\Messenger\Message\ExportMessage;
use App\Service\Exporter;

class ExportHandler
{

    private Exporter $exporter;

    public function __construct(Exporter $exporter)
    {
        $this->exporter = $exporter;
    }

    public function __invoke(ExportMessage $message)
    {
        $this->exporter->exportUsersOlderThan($message->getMaxDate(), $message->getOwnerId());
    }
}