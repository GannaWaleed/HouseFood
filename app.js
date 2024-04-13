const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');

const app = express();
const port = 3000;

// Connect to MongoDB
mongoose.connect('mongodb+srv://ParkGanna:123Jim$$$123@houseoffood.yl2yffg.mongodb.net/?retryWrites=true&w=majority&appName=HouseOfFood', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});
const db = mongoose.connection;
db.on('error', (error) => {
    console.error('MongoDB connection error:', error);
});
db.once('open', () => {
    console.log('Connected to MongoDB');
});


// Define a schema for the user data
const userSchema = new mongoose.Schema({
  firstName: String,
  lastName: String,
  phone: Number,
  id: Number,
  address: String,
  email: String,
  password: String,
   isHomeMaker: Boolean,
   isAvailable: Boolean
});
// Define a model based on the schema
const User = mongoose.model('User', userSchema);

app.use(bodyParser.urlencoded({ extended: true }));
// Parse JSON bodies
app.use(bodyParser.json());

// Handle POST requests to /register
app.post('/register', async (req, res) => {
  const { firstName, lastName, phone, id, address, email, password, isHomeMaker, isAvailable} = req.body;
  try {
    console.log('Trying to find existing user...');
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    console.log('Existing user:', existingUser);
    if (existingUser) {
      console.log('User already exists');
      return res.status(400).json({ error: 'User already exists' });
    }
    console.log('User does not exist');
  // Create a new user object based on the request body
  const newUser = new User({
    firstName,
    lastName,
    phone,
    id,
    address,
    email,
    password,
     isHomeMaker: !!isHomeMaker,
      isAvailable: !!isAvailable
  });
  await newUser.save();
  console.log('User ID:', newUser._id);
  console.log('5');
  // Return success response
 res.status(200).json({ userId: newUser._id });
} catch (error) {
  console.log('6');
  console.error('Error registering user:', error);
  res.status(500).json({ error: 'Internal server error' });
}
});

app.get('/register', async (req, res) => {
  try {
    // Find users where isHomeMaker is true
    const homemakers = await User.find({ isHomeMaker: true });
    res.json(homemakers);
  } catch (error) {
    console.error('Error fetching homemakers:', error);
    res.status(500).json({ error: 'An error occurred while fetching homemakers' });
  }
});

app.get('/register/:id', async (req, res) => {
  const userId = req.params.id;
  try {
    const user = await User.findById(ObjectId(userId));
       if (!user) {
         return res.status(404).json({ error: 'User not found' });
       }
    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'An error occurred while fetching user' });
  }
});

 app.get('/users/:id', async (req, res) => {
   const userId = req.params.id;
   try {
     if (!mongoose.Types.ObjectId.isValid(userId)) {
       return res.status(400).json({ error: 'Invalid user ID' });
     }
     const user = await User.findById(userId);
     if (!user) {
       return res.status(404).json({ error: 'User not found' });
     }
     res.json(user);
   } catch (error) {
     console.error('Error fetching user:', error);
     res.status(500).json({ error: 'An error occurred while fetching user' });
   }
 });

  app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
      const user = await User.findOne({ email, password });
      if (user) {
        res.status(200).json({ success: true, userId: user._id });
      } else {
        res.status(401).json({ success: false, message: 'Invalid email or password' });
      }
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Internal server error' });
    }
  });

// Start the server
app.listen(port, () => {
  console.log(`Server is running on ${port}`);
});
