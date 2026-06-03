package dao;

import model.Evaluates;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class EvaluateDAO extends ADAO implements IDAO<Evaluates, String> {

    public List<Evaluates> getByUserId(int userId) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                        SELECT 
                            e.product_id, 
                            e.user_id, 
                            e.evaluate_id
                        FROM evaluates e
                        WHERE e.user_id = :userId
                        ORDER BY e.evaluate_id DESC
                        """)
                .bind("userId", userId)
                .mapToBean(Evaluates.class)
                .list());
    }

    @Override
    public List<Evaluates> findAll() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT evaluate_id, user_id, product_id FROM evaluates")
                .mapToBean(Evaluates.class)
                .list());
    }

    @Override
    public Optional<Evaluates> findById(String id) {
        return Optional.ofNullable(jdbi.withHandle(handle -> handle.createQuery("""
                            SELECT evaluate_id, user_id, product_id FROM evaluates WHERE product_id = :id
                        """)
                .bind("id", id)
                .mapToBean(Evaluates.class)
                .findFirst()
                .orElse(null)));
    }

    @Override
    public Evaluates save(Evaluates entity) {
        return jdbi.withHandle(handle -> {
            boolean exists = handle.createQuery("SELECT count(*) FROM evaluates WHERE product_id = :id AND user_id = :userId")
                    .bindBean(entity)
                    .mapTo(Integer.class)
                    .one() > 0;
                    
            if (!exists) {
                handle.createUpdate("""
                                INSERT INTO evaluates (product_id, user_id, evaluate_id)
                                VALUES (:id, :userId, :evaluatesId)
                                """)
                        .bindBean(entity)
                        .execute();
            } else {
                handle.createUpdate("""
                                UPDATE evaluates SET
                                    evaluate_id = :evaluatesId
                                WHERE product_id = :id AND user_id = :userId
                                """)
                        .bindBean(entity)
                        .execute();
            }
            return entity;
        });
    }

    @Override
    public boolean deleteById(String id) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                            DELETE FROM evaluates WHERE product_id = :id
                        """)
                .bind("id", id)
                .execute() > 0);
    }

    @Override
    public boolean existsById(String id) {
        return findById(id).isPresent();
    }
}
