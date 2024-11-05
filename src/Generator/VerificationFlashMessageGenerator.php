<?php

/*
 * This file is part of the Sylius package.
 *
 * (c) Sylius Sp. z o.o.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace App\Generator;

use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
use Symfony\Contracts\Translation\TranslatorInterface;

final class VerificationFlashMessageGenerator implements FlashMessageGeneratorInterface
{
    public function __construct(
        private readonly UrlGeneratorInterface $urlGenerator,
        private readonly TranslatorInterface $translator
    ) {
    }

    /**
     * {@inheritdoc}
     */
    public function generate(string $token): string
    {
        $url = $this
            ->urlGenerator
            ->generate('sylius_shop_user_verification', ['token' => $token], UrlGeneratorInterface::ABSOLUTE_URL)
        ;

        return $this->translator->trans('sylius_demo.verification_link_flash', [
            '%url%' => $url,
        ]);
    }
}
