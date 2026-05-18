package dao;

import model.ReviewViewModel;

import java.util.List;

public class ReviewDAO extends ADAO {

    public List<ReviewViewModel> getAllReviews() {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT 
                    ct.id,
                    ct.content,
                    ct.star,
                    ct.create_at,
                    ct.update_at,
                    ct.is_delete,
                    e.product_id,
                    e.user_id,
                    COALESCE(u.full_name, u.username, u.email) as user_name,
                    u.email as user_email,
                    p.product_name
                FROM ct_evaluates ct
                JOIN evaluates e ON ct.id = e.evaluate_id
                LEFT JOIN users u ON e.user_id = u.id
                LEFT JOIN products p ON e.product_id = p.id
                ORDER BY ct.create_at DESC
                """)
                .mapToBean(ReviewViewModel.class)
                .list());
    }

    public List<ReviewViewModel> getAllActiveReviews() {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT 
                    ct.id,
                    ct.content,
                    ct.star,
                    ct.create_at,
                    ct.update_at,
                    ct.is_delete,
                    e.product_id,
                    e.user_id,
                    COALESCE(u.full_name, u.username, u.email) as user_name,
                    u.email as user_email,
                    p.product_name
                FROM ct_evaluates ct
                JOIN evaluates e ON ct.id = e.evaluate_id
                LEFT JOIN users u ON e.user_id = u.id
                LEFT JOIN products p ON e.product_id = p.id
                WHERE ct.is_delete IS NULL
                ORDER BY ct.create_at DESC
                """)
                .mapToBean(ReviewViewModel.class)
                .list());
    }

    public ReviewViewModel getReviewById(int id) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT 
                    ct.id,
                    ct.content,
                    ct.star,
                    ct.create_at,
                    ct.update_at,
                    ct.is_delete,
                    e.product_id,
                    e.user_id,
                    COALESCE(u.full_name, u.username, u.email) as user_name,
                    u.email as user_email,
                    p.product_name
                FROM ct_evaluates ct
                JOIN evaluates e ON ct.id = e.evaluate_id
                LEFT JOIN users u ON e.user_id = u.id
                LEFT JOIN products p ON e.product_id = p.id
                WHERE ct.id = :id
                """)
                .bind("id", id)
                .mapToBean(ReviewViewModel.class)
                .findFirst()
                .orElse(null));
    }

    public boolean deleteReview(int id) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                UPDATE ct_evaluates 
                SET is_delete = NOW(), update_at = NOW()
                WHERE id = :id
                """)
                .bind("id", id)
                .execute() > 0);
    }

    public boolean hardDeleteReview(int id) {
        return jdbi.inTransaction(handle -> {
            // Xóa từ evaluates trước (foreign key)
            handle.createUpdate("DELETE FROM evaluates WHERE evaluate_id = :id")
                    .bind("id", id)
                    .execute();
            // Sau đó xóa từ ct_evaluates
            return handle.createUpdate("DELETE FROM ct_evaluates WHERE id = :id")
                    .bind("id", id)
                    .execute() > 0;
        });
    }

    public boolean restoreReview(int id) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                UPDATE ct_evaluates 
                SET is_delete = NULL, update_at = NOW()
                WHERE id = :id
                """)
                .bind("id", id)
                .execute() > 0);
    }

    public boolean updateReview(int id, String content, double star) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                UPDATE ct_evaluates 
                SET content = :content, star = :star, update_at = NOW()
                WHERE id = :id
                """)
                .bind("id", id)
                .bind("content", content)
                .bind("star", star)
                .execute() > 0);
    }

    public List<ReviewViewModel> getReviewsByProduct(String productId) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT 
                    ct.id,
                    ct.content,
                    ct.star,
                    ct.create_at,
                    ct.update_at,
                    ct.is_delete,
                    e.product_id,
                    e.user_id,
                    COALESCE(u.full_name, u.username, u.email) as user_name,
                    u.email as user_email,
                    p.product_name
                FROM ct_evaluates ct
                JOIN evaluates e ON ct.id = e.evaluate_id
                LEFT JOIN users u ON e.user_id = u.id
                LEFT JOIN products p ON e.product_id = p.id
                WHERE e.product_id = :productId AND ct.is_delete IS NULL
                ORDER BY ct.create_at DESC
                """)
                .bind("productId", productId)
                .mapToBean(ReviewViewModel.class)
                .list());
    }

    public List<ReviewViewModel> getReviewsByUser(int userId) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT 
                    ct.id,
                    ct.content,
                    ct.star,
                    ct.create_at,
                    ct.update_at,
                    ct.is_delete,
                    e.product_id,
                    e.user_id,
                    COALESCE(u.full_name, u.username, u.email) as user_name,
                    u.email as user_email,
                    p.product_name
                FROM ct_evaluates ct
                JOIN evaluates e ON ct.id = e.evaluate_id
                LEFT JOIN users u ON e.user_id = u.id
                LEFT JOIN products p ON e.product_id = p.id
                WHERE e.user_id = :userId AND ct.is_delete IS NULL
                ORDER BY ct.create_at DESC
                """)
                .bind("userId", userId)
                .mapToBean(ReviewViewModel.class)
                .list());
    }

    public List<ReviewViewModel> getReviewsByStar(double star) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT 
                    ct.id,
                    ct.content,
                    ct.star,
                    ct.create_at,
                    ct.update_at,
                    ct.is_delete,
                    e.product_id,
                    e.user_id,
                    COALESCE(u.full_name, u.username, u.email) as user_name,
                    u.email as user_email,
                    p.product_name
                FROM ct_evaluates ct
                JOIN evaluates e ON ct.id = e.evaluate_id
                LEFT JOIN users u ON e.user_id = u.id
                LEFT JOIN products p ON e.product_id = p.id
                WHERE ct.star = :star AND ct.is_delete IS NULL
                ORDER BY ct.create_at DESC
                """)
                .bind("star", star)
                .mapToBean(ReviewViewModel.class)
                .list());
    }

    public int countAllReviews() {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT COUNT(*) FROM ct_evaluates WHERE is_delete IS NULL
                """)
                .mapTo(Integer.class)
                .findFirst()
                .orElse(0));
    }

    public double getAverageRating() {
        return jdbi.withHandle(handle -> handle.createQuery("""
                SELECT COALESCE(AVG(star), 0) FROM ct_evaluates WHERE is_delete IS NULL
                """)
                .mapTo(Double.class)
                .findFirst()
                .orElse(0.0));
    }
}
