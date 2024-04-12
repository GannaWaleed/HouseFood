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
  //////////////////////////////////////////////////////////
  const ratingSchema = new mongoose.Schema({
    rating: Number,
    chefId: String,
  });

  const Rating = mongoose.model('Rating', ratingSchema);

  // Middleware to parse JSON bodies
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  // Handle POST requests to /rateChef
  app.post('/rateChef', async (req, res) => {
    const { rating, chefId } = req.body;
    const userId = req.headers['user-id']; // Assuming userId is sent in request headers

    try {
      // Check if the user has already rated the chef
      const existingRating = await Rating.findOne({ chefId, userId });
      if (existingRating) {
        return res.status(400).json({ error: 'You have already rated this chef' });
      }

      // Prevent the chef from rating themselves
      if (chefId === userId) {
        return res.status(400).json({ error: 'You cannot rate yourself' });
      }

      // Create a new rating document using Mongoose model
      const newRating = new Rating({
        rating,
        chefId,
        userId
      });

      // Save the new rating document to the database
      await newRating.save();

      res.status(200).json({ message: 'Rating saved successfully' });
    } catch (error) {
      console.error('Error saving rating:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });


  // Handle GET requests to /chefAverageRating/:chefId
  // Handle GET requests to /chefAverageRating/:chefId
  app.get('/chefAverageRating/:chefId', async (req, res) => {
    const { chefId } = req.params;
    const userId = req.headers['user-id']; // Assuming userId is sent in request headers

    try {
      // Find all ratings for the specified chef
      const chefRatings = await Rating.find({ chefId });

      if (chefRatings.length === 0) {
        // If there are no ratings for the chef, return 0 as the average rating
        return res.status(200).json({ averageRating: 0 });
      }


      // Check if the user has already rated the chef
      const userRating = chefRatings.find(rating => rating.userId === userId);
      if (userRating) {
        // If the user has already rated the chef, display a Snackbar message
        return res.status(400).json({ error: 'You have already rated this chef' });
      }

      // Prevent the chef from rating themselves
      if (chefId === userId) {
        // If the chef has already rated themselves, display a Snackbar message
        return res.status(400).json({ error: 'You cannot rate yourself' });
      }

      // Calculate the total sum of ratings
      const totalRating = chefRatings.reduce((sum, rating) => sum + rating.rating, 0);

         // Calculate the average rating
         const averageRating = totalRating / chefRatings.length;

         res.status(200).json({ averageRating });
       } catch (error) {
         console.error('Error calculating average rating:', error);
         res.status(500).json({ error: 'Internal server error' });
       }
     });

// Start the server
app.listen(port, () => {
  console.log(`Server is running on ${port}`);
});
