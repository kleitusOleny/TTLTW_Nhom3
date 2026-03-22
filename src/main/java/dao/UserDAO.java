package dao;

import model.User;

import java.util.List;
import java.util.Optional;

public class UserDAO extends ADAO implements IDAO<User, Integer> {

    @Override
    public List<User> findAll() {
        return jdbi.withHandle(handle -> handle.createQuery("""
                         SELECT\s
                             id,
                             email,\s
                             username,
                             password_hash,
                             phone_number,
                             active,\s
                             created_at,
                             birth_day,
                             full_name,
                             administrator
                         FROM users
                        \s""")
                .mapToBean(User.class)
                .list());
    }

    @Override
    public Optional<User> findById(Integer id) {
        return Optional.of(jdbi.withHandle(handle ->
                handle.createQuery("""
                                    SELECT id, email, username,
                                           password_hash,
                                           phone_number,
                                           full_name,
                                           birth_day,
                                           administrator,
                                           active,
                                           created_at,
                                           update_at
                                    FROM users
                                    WHERE id = :id
                                """)
                        .bind("id", id)
                        .mapToBean(User.class)
                        .findFirst()
                        .orElse(null)
        ));
    }

    @Override
    public User save(User entity) {
        return jdbi.withHandle(handle -> {
            if (entity.getId() == null) {
                Integer id = handle.createUpdate("""
                                INSERT INTO users
                                (email, username, password_hash, phone_number, full_name,
                                 birth_day, administrator, active, created_at)
                                VALUES
                                (:email, :username, :passwordHash, :phoneNumber, :fullName,
                                 :birthDay, :administrator, :active, :createdAt)
                                """)
                        .bind("email", entity.getEmail())
                        .bind("username", entity.getUsername())
                        .bind("passwordHash", entity.getPasswordHash())
                        .bind("phoneNumber", entity.getPhoneNumber())
                        .bind("fullName", entity.getFullName())
                        .bind("birthDay", entity.getBirthDay())
                        .bind("administrator", entity.getAdministrator())
                        .bind("active", entity.getActive())
                        .bind("createdAt", entity.getCreatedAt())
                        .executeAndReturnGeneratedKeys("id")
                        .mapTo(Integer.class)
                        .one();

                entity.setId(id);

            } else {
                boolean hasPassword = entity.getPasswordHash() != null
                        && !entity.getPasswordHash().trim().isEmpty();
                StringBuilder sql = new StringBuilder("UPDATE users SET ");
                sql.append("username = :username, ");
                sql.append("full_name = :full_name, ");
                sql.append("email = :email, ");

                if (hasPassword) {
                    sql.append("password_hash = :password_hash, ");
                }

                sql.append("phone_number = :phone_number, ");
                sql.append("birth_day = :birth_day, ");
                sql.append("active = :active, ");
                sql.append("update_at = :update_at, ");
                sql.append("administrator = :administrator ");
                sql.append("WHERE id = :id");

                int rows = handle.createUpdate(sql.toString())
                        .bind("id", entity.getId())
                        .bind("username", entity.getUsername())
                        .bind("full_name", entity.getFullName())
                        .bind("email", entity.getEmail())
                        .bind("phone_number", entity.getPhoneNumber())
                        .bind("birth_day", entity.getBirthDay())
                        .bind("active", entity.getActive())
                        .bind("administrator", entity.getAdministrator())
                        .bind("update_at", entity.getUpdateAt())
                        .bind("password_hash", hasPassword ? entity.getPasswordHash() : null)
                        .execute();
                if (rows == 0) {
                    throw new RuntimeException("Update failed: User not found with id = " + entity.getId());
                }
            }
            return entity;
        });
    }

    @Override
    public void deleteById(Integer id) {
        jdbi.withHandle(handle -> handle.createUpdate("""
                            UPDATE users 
                            SET active:= 0
                            WHERE id:=id
                        """)
                .bind("id", id)
                .execute() > 0);
    }

    @Override
    public boolean existsById(Integer id) {
        return findById(id) != null;
    }

    public boolean updateActiveStatus(User entity) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                        UPDATE users
                        SET
                        active=:active
                        WHERE id=:id""")
                .bind("id", entity.getId())
                .bind("active", entity.getActive())
                .execute() > 0);
    }

    public User findByEmail(String email) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                        SELECT
                            id,
                            email,
                            username,
                            password_hash AS passwordHash,
                            phone_number AS phoneNumber,
                            full_name AS fullName,
                            birth_day AS birthDay,
                            administrator,
                            active,
                            created_at AS createdAt,
                            update_at AS updateAt
                        FROM users
                        WHERE email=:email
                        """)
                .bind("email", email)
                .mapToBean(User.class)
                .findFirst()
                .orElse(null));
    }

    public User findByUsername(String username) {
        return jdbi.withHandle(handle -> handle.createQuery("""
                        SELECT
                            id,
                            email,
                            username,
                            password_hash AS passwordHash,
                            phone_number AS phoneNumber,
                            full_name AS fullName,
                            birth_day AS birthDay,
                            administrator,
                            active,
                            created_at AS createdAt,
                            update_at AS updateAt
                        FROM users
                        WHERE username=:username
                        """)
                .bind("username", username)
                .mapToBean(User.class)
                .findFirst()
                .orElse(null));
    }

    public boolean updatePassword(String email, String newPasswordHashed) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                        update users set password_hash =:passwordHash where email=:email""")
                .bind("passwordHash", newPasswordHashed)
                .bind("email", email).execute() > 0);
    }

    public boolean updateActive(int id, int activeNum) {
        return jdbi.withHandle(handle -> handle.createUpdate("""
                        update users set active = :activeNum where id = :id""")
                .bind("activeNum", activeNum)
                .bind("id", id)
                .execute() > 0);
    }

    public int countUserId(String email) {
        return jdbi.withHandle(handle -> handle.createQuery("select count(id) from users where email = :email")
                .bind("email", email)
                .mapTo(Integer.class)
                .findOnly());
    }

    public int countNewUsersLastWeek() {
        return jdbi.withHandle(handle -> handle.createQuery(
                        "select COUNT(id) from users where created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")
                .mapTo(Integer.class)
                .findOnly());
    }
}
