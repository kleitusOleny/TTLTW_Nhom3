package dao;

import model.CTEvaluates;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class CTEvaluateDAO extends ADAO implements IDAO<CTEvaluates, Integer> {


    public int createAndReturnId(CTEvaluates entity) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                        INSERT INTO ct_evaluates
                        (content, star, create_at, update_at, is_delete, image_path)
                        VALUES (:content, :star, :create_at, :update_at, :is_delete, :image_path)
                        """)
                .bind("content", entity.getContent())
                .bind("star", entity.getStar())
                .bind("create_at", entity.getCreateAt())
                .bind("update_at", entity.getUpdateAt())
                .bind("is_delete", entity.isDelete() ? java.time.LocalDateTime.now() : null)
                .bind("image_path", entity.getImagePath())
                .executeAndReturnGeneratedKeys("id")
                .mapTo(Integer.class)
                .one());
    }

    public List<CTEvaluates> getByStar(double star) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                        SELECT id, content, star, create_at, update_at, is_delete, image_path FROM ct_evaluates
                        WHERE star = :star AND is_delete IS NULL
                        """)
                .bind("star", star)
                .mapToBean(CTEvaluates.class)
                .list());
    }

    @Override
    public List<CTEvaluates> findAll() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT id, content, star, create_at, update_at, is_delete, image_path FROM ct_evaluates WHERE is_delete IS NULL")
                .mapToBean(CTEvaluates.class)
                .list());
    }

    @Override
    public Optional<CTEvaluates> findById(Integer id) {
        return Optional.of(jdbi.withHandle(
                handle -> Objects.requireNonNull(handle.createQuery("SELECT id, content, star, create_at, update_at, is_delete, image_path FROM ct_evaluates WHERE id = :id AND is_delete IS NULL")
                        .bind("id", id)
                        .mapToBean(CTEvaluates.class)
                        .findFirst()
                        .orElse(null))));
    }

    @Override
    public CTEvaluates save(CTEvaluates entity) {
        return jdbi.withHandle(handle -> {
            if (entity.getId() == null) {
                int generatedId = handle.createUpdate("""
                                INSERT INTO ct_evaluates
                                (content, star, create_at, update_at, is_delete, image_path)
                                VALUES (:content, :star, :createAt, :updateAt, :isDelete, :imagePath)
                                """)
                        .bindBean(entity)
                        .bind("isDelete", entity.isDelete() ? java.time.LocalDateTime.now() : null)
                        .executeAndReturnGeneratedKeys("id")
                        .mapTo(int.class).one();
                entity.setId(generatedId);
            } else {
                handle.createUpdate("""
                                UPDATE ct_evaluates SET
                                    content = :content,
                                    star = :star,
                                    update_at = :updateAt,
                                    is_delete = :isDelete,
                                    image_path = :imagePath
                                WHERE id = :id
                                """)
                        .bindBean(entity)
                        .bind("isDelete", entity.isDelete() ? java.time.LocalDateTime.now() : null)
                        .execute();
            }
            return entity;
        });
    }

    @Override
    public boolean deleteById(Integer id) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                        UPDATE ct_evaluates
                        SET is_delete = NOW(), update_at = NOW()
                        WHERE id = :id
                        """)
                .bind("id", id)
                .execute() > 0);
    }

    @Override
    public boolean existsById(Integer id) {
        return findById(id).isPresent();
    }
}
