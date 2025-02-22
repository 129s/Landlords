const { v4: uuidv4 } = require('uuid');

class UserModel {
    constructor(username) {
        this.id = uuidv4();
        this.username = username;
        this.createdAt = new Date();
        this.isGuest = true;
    }
}

module.exports = UserModel;
