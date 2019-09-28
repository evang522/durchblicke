<?php

namespace App\Controller;

use App\Entity\Quote;
use PhpParser\Error;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;

class QuoteController extends AbstractController
{
    /**
     * @Route("/quote", name="quote", methods={"POST"})
     * @param ValidatorInterface $validator
     * @return Response
     */
    public function createNewProduct(ValidatorInterface $validator)
    {
        $request = Request::createFromGlobals();
        $parsedRequestBody = json_decode($request->getContent());

        $errorResponse = [
            "error" => true,
            "Reason" => "Quote Validation Failed"
        ];

        try {
            $quote = new Quote();
            $quote->setAuthor($parsedRequestBody->author);
            $quote->setBody($parsedRequestBody->body);
            $quote->setDescription($parsedRequestBody->description);
            $quote->setSource($parsedRequestBody->source);

            $errors = $validator->validate($quote);
            if (count($errors) > 1) {
                throw new Error('Validation Failed');
            }

            $entityManager = $this->getDoctrine()->getManagerForClass(Quote::class);
            $entityManager->persist($quote);
            $entityManager->flush();

            return new JsonResponse(json_encode($quote));
        } catch (\Exception $e) {
            return new JsonResponse(["error" =>$e->getMessage()]);
        }
    }


    /**
     * @Route("/quote/{id}", name="get_quote_by_id", methods={"GET"})
     * @param $id
     * @return Response
     */
    public function getQuoteById($id)
    {
        try {
            $quoteRepository = $this->getDoctrine()->getRepository(Quote::class);
            $quote = $quoteRepository->find($id);
            return new JsonResponse($quote->toJson());
        } catch (\Exception $e) {
            return new JsonResponse(["error" => $e->getMessage()]);
        }

    }

    /**
     * @Route("/quote/", name="get_quote_by_id", methods={"GET"})
     * @return Response
     */
    public function findQuoteByTerms()
    {
        try {
            $request = Request::createFromGlobals();
            $term = $request->get('term');

            $quoteRepository = $this->getDoctrine()->getRepository(Quote::class);
            $quoteList = $quoteRepository->quoteListByTerm($term);
            $transformedQuotes = array_map(function (Quote $quote) {
                return $quote->toJson();
            }, $quoteList);
            return new JsonResponse($transformedQuotes);
        } catch (\Exception $e) {
            return new JsonResponse(["error" => $e->getMessage()]);
        }

    }
}
