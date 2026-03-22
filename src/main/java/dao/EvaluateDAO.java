package dao;

import model.Evaluates;
import model.User;

import java.util.List;
import java.util.Optional;

public class EvaluateDAO extends ADAO implements IDAO<Evaluates, String> {

    public List<Evaluates> getByUserId(int userId) {
        return jdbi.withHandle(handle -> handle.createQuery("""
        SELECT 
            e.product_id AS productId, 
            e.user_id AS userId, 
            e.evaluate_id AS evaluatesId,
            p.name AS productName, 
            p.image AS productImage,
            ct.content AS content, 
            ct.rating AS rating,
            ct.created_at AS createdAt
        FROM evaluates e
        JOIN products p ON e.product_id = p.id
        LEFT JOIN ct_evaluates ct ON e.evaluate_id = ct.id
        WHERE e.user_id = :userId
        ORDER BY ct.created_at DESC
        """)
                .bind("uid", userId)
                .mapToBean(Evaluates.class)
                .list());
    }

    @Override
    public List<Evaluates> findAll() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT * FROM evaluates")
                .mapToBean(Evaluates.class)
                .list());
    }

    @Override
    public Optional<Evaluates> findById(String id) {
        return Optional.of(jdbi.withHandle(handle -> handle.createQuery("""
                            SELECT * FROM evaluates WHERE product_id = :id
                        """)
                .bind("id", id)
                .mapToBean(Evaluates.class)
                .findFirst()
                .orElse(null)));
    }

    @Override
    public Evaluates save(Evaluates entity) {
        UserDAO userDAO=new UserDAO();
        CTEvaluateDAO ctEvaluateDAO=new CTEvaluateDAO();
        return jdbi.withHandle(handle -> {
            if (!existsById(entity.getId())&& !userDAO.existsById(entity.getUserId())&& !ctEvaluateDAO.existsById(entity.getEvaluatesId())) {
                 handle.createUpdate("""
                            INSERT INTO evaluates (product_id, user_id, evaluate_id)
                            VALUES (:id, :userId, :evaluatesId)
                            """)
                        .bindBean(entity)
                        .executeAndReturnGeneratedKeys("product_id")
                        .mapTo(String.class)
                        .one();
            } else {
                handle.createUpdate("""
                            UPDATE evaluates SET
                                user_id = :userId,
                                evaluate_id = :evaluatesId
                            WHERE product_id = :id
                            """)
                        .bindBean(entity)
                        .execute();
            }
            return entity;
        });
    }

    @Override
    public void deleteById(String id) {
        jdbi.withHandle(handle -> handle.createUpdate("""
                            DELETE FROM evaluates WHERE product_id = :id
                        """)
                .bind("id", id)
                .execute() > 0);
    }

    @Override
    public boolean existsById(String id) {
        return findById(id) != null;
    }
}
