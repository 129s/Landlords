const express = require('express');
const router = express.Router();

router.post('/guest', (req, res) => {
  const { username } = req.body;
  if (!username) {
    return res.status(400).json({ message: '用户名不能为空' });
  }
  const user = global.authService.guestLogin(username);
  res.json(user);
});

module.exports = router;
