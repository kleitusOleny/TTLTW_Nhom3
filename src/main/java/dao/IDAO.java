package dao;

import java.util.List;
import java.util.Optional;

public interface IDAO<T, ID> {

    List<T> findAll();

    Optional<T> findById(ID id);

    T save(T entity);

    boolean deleteById(ID id);

    boolean existsById(ID id);
}
