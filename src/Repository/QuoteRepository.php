<?php

namespace App\Repository;

use App\Entity\Quote;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Common\Persistence\ManagerRegistry;

/**
 * @method Quote|null find($id, $lockMode = null, $lockVersion = null)
 * @method Quote|null findOneBy(array $criteria, array $orderBy = null)
 * @method Quote[]    findAll()
 * @method Quote[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class QuoteRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Quote::class);
    }

    /**
     * @param $term
     * @return void Returns an array of Quote objects
     */

    public function quoteListByTerm($term)
    {
        $qb = $this->createQueryBuilder('q');
        return $qb
            ->where('LOWER(q.author) LIKE :term')
            ->orWhere('LOWER(q.description) LIKE :term')
            ->orWhere('LOWER(q.source) LIKE :term')
            ->orWhere('LOWER(q.body) LIKE :term')
            ->setParameter('term', '%' . strtolower($term) . '%')
            ->setMaxResults(20)
            ->getQuery()
            ->getResult()
        ;
    }


    /*
    public function findOneBySomeField($value): ?Quote
    {
        return $this->createQueryBuilder('q')
            ->andWhere('q.exampleField = :val')
            ->setParameter('val', $value)
            ->getQuery()
            ->getOneOrNullResult()
        ;
    }
    */
}
