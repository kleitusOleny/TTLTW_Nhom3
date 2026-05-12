package dao;

import model.UserVoucher;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class UserVoucherDAO extends ADAO implements IDAO<UserVoucher, Integer> {


    public List<UserVoucher> findByUserId(int userId) {
        return jdbi.withHandle(
                handle -> handle.createQuery("SELECT id, user_id, discount_id, is_used, create_at FROM user_vouchers WHERE user_id = :userId AND is_used = 0")
                        .bind("userId", userId)
                        .mapToBean(UserVoucher.class)
                        .list());
    }


    public boolean markAsUsed(int id) {
        return jdbi.withHandle(handle -> handle.createUpdate("UPDATE user_vouchers SET is_used = 1 WHERE id = :id")
                .bind("id", id)
                .execute() > 0);
    }

    @Override
    public List<UserVoucher> findAll() {
        return jdbi.withHandle(handle -> handle.createQuery("SELECT * FROM user_vouchers")
                .mapToBean(UserVoucher.class)
                .list());
    }

    @Override
    public Optional<UserVoucher> findById(Integer id) {
        return Optional.of(jdbi.withHandle(handle -> Objects.requireNonNull(handle.createQuery("SELECT * FROM user_vouchers WHERE id = :id")
                .bind("id", id)
                .mapToBean(UserVoucher.class)
                .findFirst()
                .orElse(null))));
    }

    @Override
    public UserVoucher save(UserVoucher entity) {
        return jdbi.withHandle(handle -> {
            if (entity.getId() == null) {
                Integer id = handle.createUpdate("""
                    INSERT INTO user_vouchers
                    (user_id, discount_id, is_used, created_at)
                    VALUES (:userId, :discountId, :isUsed, :createdAt)
                    """)
                        .bindBean(entity)
                        .executeAndReturnGeneratedKeys("id")
                        .mapTo(Integer.class)
                        .one();

                entity.setId(id);

            } else {
                int rows = handle.createUpdate("""
                    UPDATE user_vouchers
                    SET is_used = :isUsed
                    WHERE id = :id
                    """)
                        .bind("isUsed", entity.isUsed())
                        .bind("id", entity.getId())
                        .execute();

                if (rows == 0) {
                    throw new RuntimeException("Update failed: UserVoucher not found with id = " + entity.getId());
                }
            }

            return entity;
        });
    }

    @Override
    public boolean deleteById(Integer id) {
        jdbi.withHandle(handle -> handle.createUpdate("DELETE FROM user_vouchers WHERE id = :id")
                .bind("id", id)
                .execute() > 0);
        return false;
    }

    @Override
    public boolean existsById(Integer integer) {
        return findById(integer).isPresent();
    }
}
