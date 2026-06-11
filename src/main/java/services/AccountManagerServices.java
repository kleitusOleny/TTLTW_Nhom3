package services;

import dao.UserDAO;
import model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class AccountManagerServices {
    UserDAO userDAO = new UserDAO();

    public boolean addAccount(String email, String plainPassword) {
        if (userDAO.countUserId(email) > 0) return false;
        String hashedPass = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));

        User user = new User();
        user.setEmail(email);
        user.setUsername(null);
        user.setPasswordHash(hashedPass);
        user.setPhoneNumber(null);
        user.setFullName(null);
        user.setBirthDay(null);
        user.setActive(1);
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        return userDAO.save(user)!=null;
    }

    public void updateAccount(int id, String email, String plainPassword, String fullName, String birth, String username, String phoneNumber, String isActive) throws ParseException {
        User currentUser = userDAO.findById(id).orElse(null);

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date parsedDate = dateFormat.parse(birth);
        java.sql.Timestamp birthTimestamp = new java.sql.Timestamp(parsedDate.getTime());

        if (currentUser != null) {
            currentUser.setEmail(email);
            if (plainPassword != null) {
                String hashedPass = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
                currentUser.setPasswordHash(hashedPass);
            }
            currentUser.setFullName(fullName);
            currentUser.setBirthDay(birthTimestamp);
            currentUser.setUsername(username);
            currentUser.setPhoneNumber(phoneNumber);
            currentUser.setActive(Integer.parseInt(isActive));
            currentUser.setUpdateAt(new Timestamp(System.currentTimeMillis()));
            userDAO.save(currentUser);
        }
    }

    public boolean toggleStatus(int id){
        User currentUser = userDAO.findById(id).orElse(null);
        if (currentUser != null) {
            int newStatus = (currentUser.getActive() == 1) ? 0 : 1;
            Timestamp currentTime = new Timestamp(System.currentTimeMillis());
            return userDAO.updateActive(currentUser.getId(), newStatus, currentTime);
        }
        return false;
    }

    public void updateStatus(int id, int status) {
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
        userDAO.updateActive(id, status, currentTime);
    }
}
