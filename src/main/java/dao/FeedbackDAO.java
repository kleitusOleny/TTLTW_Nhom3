package dao;

import model.Feedback;

import java.util.List;
import java.util.Optional;

public class FeedbackDAO extends ADAO implements IDAO<Feedback, Integer> {
    public List<Feedback> getPendingFeedbacks() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT id, user_id, title, content, create_at, update_at, is_delete FROM feedback where status = 0 AND is_delete = 0 ORDER BY create_at DESC")
                .mapToBean(Feedback.class)
                .list());
    }

    public List<Feedback> getCompletedFeedbacks() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT id, user_id, title, content, create_at, update_at, is_delete FROM feedback where status = 1 AND is_delete = 0 ORDER BY create_at DESC")
                .mapToBean(Feedback.class)
                .list());
    }


    @Override
    public List<Feedback> findAll() {
        return List.of();
    }

    @Override
    public Optional<Feedback> findById(Integer id) {
        return jdbi.withHandle(handle ->
                handle.createQuery("""
                                    SELECT id, user_id, title, content, create_at, update_at, is_delete FROM feedback
                                    WHERE id = :id AND is_delete = 0
                                """)
                        .bind("id", id)
                        .mapToBean(Feedback.class)
                        .findFirst()
        );
    }

    @Override
    public Feedback save(Feedback entity) {
        return jdbi.withHandle(handle -> {
            if (entity.getId() == null) {
                Integer id = handle.createUpdate("""
                                INSERT INTO feedback
                                (user_id, title, content, create_at, is_delete, status)
                                VALUES (:user_id, :title, :content, :create_at, :is_delete, :status)
                                """)
                        .bind("user_id", entity.getuId())
                        .bind("title", entity.getTitle())
                        .bind("content", entity.getContent())
                        .bind("create_at", entity.getCreateAt())
                        .bind("is_delete", entity.isDelete())
                        .bind("status", entity.isStatus())
                        .executeAndReturnGeneratedKeys("id")
                        .mapTo(Integer.class)
                        .one();
                entity.setId(id);
            } else {
                int rows = handle.createUpdate("""
                                UPDATE feedback SET
                                    status = :status,
                                    update_at = :update_at
                                WHERE id = :id
                                """)
                        .bind("status", entity.isStatus())
                        .bind("update_at", entity.getUpdateAt())
                        .bind("id", entity.getId())
                        .execute();
                if (rows == 0) {
                    throw new RuntimeException("Update failed: Feedback not found with id = " + entity.getId());
                }
            }
            return entity;
        });
    }

    @Override
    public boolean deleteById(Integer id) {
        return jdbi.withHandle(handle -> handle.createUpdate("UPDATE feedback SET is_delete = 1 WHERE id =:id")
                .bind("id", id)
                .execute() > 0);
    }

    @Override
    public boolean existsById(Integer id) {

        return findById(id).isPresent();
    }

}
