<?php

namespace App\Messenger\Message;

use DateTime;

class ExportMessage
{
    private DateTime $maxDate;
    private int $ownerId;
    private string $receiverEmail;

    public function __construct(DateTime $maxDate, int $ownerId, string $receiverEmail)
    {
        $this->maxDate = $maxDate;
        $this->ownerId = $ownerId;
        $this->receiverEmail = $receiverEmail;
    }

    public function getReceiverEmail(): string
    {
        return $this->receiverEmail;
    }

    public function getOwnerId(): int
    {
        return $this->ownerId;
    }

    public function getMaxDate(): DateTime
    {
        return $this->maxDate;
    }
}