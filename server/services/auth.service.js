class AuthService {
    constructor() {
        this.users = new Map();
    }

    guestLogin(username) {
        const user = new UserModel(username);
        this.users.set(user.id, user);
        return user;
    }

    getUser(userId) {
        return this.users.get(userId);
    }
}

module.exports = AuthService;
