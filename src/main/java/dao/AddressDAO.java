package dao;

import model.Address;

import java.util.List;
import java.util.Optional;

public class AddressDAO extends ADAO implements IDAO<Address, Integer> {

    public List<Address> getByUserID(int id) {
        return jdbi.withHandle(handle -> {
            return handle.createQuery(
                            "SELECT * FROM addresses WHERE user_id = :user_id")
                    .bind("user_id", id)
                    .mapToBean(Address.class)
                    .list();
        });
    }

    public void setDefault(Address address) {
        address.setDefault(true);
        jdbi.withHandle(handle -> handle.createUpdate("""
                         UPDATE addresses
                         SET is_default = :is_default
                         WHERE user_id = :user_id AND id = :id
                        """)
                .bind("user_id", address.getUserId())
                .bind("id", address.getId())
                .bind("is_default", address.isDefault())
                .execute());
    }

    public void unsetAllDefaults(int userId) {
        jdbi.withHandle(handle -> handle.createUpdate("""
                         UPDATE addresses
                         SET is_default = false
                         WHERE user_id = :user_id
                        """)
                .bind("user_id", userId)
                .execute());
    }

    @Override
    public List<Address> findAll() {
        return jdbi.withHandle(handle -> {
            return handle.createQuery("SELECT * FROM addresses WHERE is_delete = 0").mapToBean(Address.class).list();
        });
    }

    @Override
    public Optional<Address> findById(Integer integer) {
        return jdbi.withHandle(handle ->
                handle.createQuery("""
                                SELECT 
                                    id,
                                    user_id,
                                    full_name,
                                    phone_number,
                                    address_line,
                                    city,
                                    district,                                
                                    ward,
                                    is_default
                                FROM addresses
                                WHERE id = :id
                                """)
                        .bind("id", integer)
                        .mapToBean(Address.class)
                        .findFirst()
        );
    }

    @Override
    public Address save(Address entity) {

        return jdbi.withHandle(handle -> {

            boolean exists = entity.getId() > 0 &&
                    handle.createQuery("""
                                        SELECT COUNT(*)
                                        FROM addresses
                                        WHERE user_id = :user_id
                                          AND id = :id
                                    """)
                            .bind("user_id", entity.getUserId())
                            .bind("id", entity.getId())
                            .mapTo(Integer.class)
                            .one() > 0;

            String sql = exists
                    ? """
                      UPDATE addresses
                      SET full_name = :full_name,
                          phone_number = :phone_number,
                          city = :city,
                          district= :district,
                          ward = :ward,
                          address_line = :address_line
                      WHERE user_id = :user_id
                        AND id = :id
                    """
                    : """
                      INSERT INTO addresses
                      (
                          user_id,
                          full_name,
                          phone_number,
                          city,
                          district,
                          ward,
                          address_line
                      )
                      VALUES
                      (
                          :user_id,
                          :full_name,
                          :phone_number,
                          :city,
                          :district,
                          :ward,
                          :address_line
                      )
                    """;

            var update = handle.createUpdate(sql)
                    .bind("user_id", entity.getUserId())
                    .bind("full_name", entity.getFullName())
                    .bind("phone_number", entity.getPhoneNumber())
                    .bind("city", entity.getCity())
                    .bind("district", entity.getDistrict())
                    .bind("ward", entity.getWard())
                    .bind("address_line", entity.getAddressLine());

            if (exists) {
                update.bind("id", entity.getId());
            }

            int affectedRows = update.execute();

            return affectedRows > 0 ? entity : null;
        });
    }

    @Override
    public boolean deleteById(Integer id) {
        return jdbi.withHandle(handle ->
                handle.createUpdate("""
                    DELETE FROM addresses
                    WHERE id = :id
                    """)
                        .bind("id", id)
                        .execute() > 0
        );
    }

    @Override
    public boolean existsById(Integer integer) {
        return this.findById(integer).isPresent();
    }
}
