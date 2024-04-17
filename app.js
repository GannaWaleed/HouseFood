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
//////////////////////////////////////////////////////
/////////////////////////////////////////////////////

 const foodItemSchema = new mongoose.Schema({
    userId: String,
     name: String,
     description: String,
     price: String,
     photo: String,
     category: String
   });

   const FoodItem = mongoose.model('FoodItem', foodItemSchema);

   app.use(bodyParser.json());

   // POST endpoint to add a new food item
   app.post('/food-items', async (req, res) => {
     const { userId, name, description, price, photo, category } = req.body; // Destructure userId from the request body
     try {
       // Create a new food item with userId included
       const foodItem = new FoodItem({ userId, name, description, price, photo, category });
       await foodItem.save();
       // Send response with the newly created food item including its id
       res.status(201).json({ id: foodItem._id, userId, name, description, price, photo, category });
     } catch (error) {
       // Handle any errors that occur during the process
       console.error('Error saving food item:', error);
       res.status(500).json({ error: 'Internal server error' });
     }
   });
   app.get('/food-items', async (req, res) => {
     const { userId } = req.query;
     try {
       const foodItems = await FoodItem.find({ userId }); // Fetch food items from MongoDB where userId matches
       res.json(foodItems);
     } catch (error) {
       console.error('Error fetching food items:', error);
       res.status(500).json({ error: 'Internal server error' });
     }
   });
   // UPDATE a food item by ID
   const { validationResult } = require('express-validator');

  app.put('/food-items/:id', async (req, res) => {
    try {
      const itemId = req.params.id;
      // Ensure itemId is a valid ObjectId
      if (!mongoose.Types.ObjectId.isValid(itemId)) {
        return res.status(400).json({ error: 'Invalid id parameter' });
      }
      // Update the food item with the specified _id
      const updatedItem = await FoodItem.findByIdAndUpdate(itemId, req.body, { new: true });
      // If the item doesn't exist, return a 404 Not Found response
      if (!updatedItem) {
        return res.status(404).json({ error: 'Food item not found' });
      }
      // Return the updated food item
      res.status(200).json(updatedItem);
    } catch (error) {
      // Handle any errors that occur during the process
      console.error('Error updating food item:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });


//   app.put('/food-items/:id', async (req, res) => {
//     try {
//         // Update the food item with the specified _id
//         const updatedItem = await FoodItem.findByIdAndUpdate(req.params.id, req.body, { new: true });
//         // If the item doesn't exist, return a 404 Not Found response
//         if (!updatedItem) {
//           return res.status(404).json({ error: 'Food item not found' });
//         }
//         // Return the updated food item
//         res.status(200).json(updatedItem);
//       } catch (error) {
//         // Handle any errors that occur during the process
//         console.error('Error updating food item:', error);
//         res.status(500).json({ error: 'Internal server error' });
//       }
//     });

   // DELETE a food item by ID
//   app.delete('/food-items/:id', async (req, res) => {
//     try {
//     const itemId = req.params.id; // Extract the id parameter from the request URL
//         console.log('Received id:', itemId); // Log the id value
//
//         // Add a check to validate the presence of the id parameter
//         if (!itemId) {
//           return res.status(400).json({ error: 'Missing id parameter' });
//         }
//         // Delete the food item with the specified _id
//         const deletedItem = await FoodItem.findByIdAndDelete(req.params.id);
//
//         // If the item doesn't exist, return a 404 Not Found response
//         if (!deletedItem) {
//           return res.status(404).json({ error: 'Food item not found' });
//         }
//
//         // Return the deleted food item
//         res.status(200).json(deletedItem);
//       } catch (error) {
//         // Handle any errors that occur during the process
//         console.error('Error deleting food item:', error);
//         res.status(500).json({ error: 'Internal server error' });
//       }
//     });
app.delete('/food-items/:id', async (req, res) => {
  try {
    const itemId = req.params.id; // Extract the id parameter from the request URL
    console.log('Received id:', itemId); // Log the id value

    // Add a check to validate the presence of the id parameter
    if (!itemId) {
      return res.status(400).json({ error: 'Missing id parameter' });
    }

    // Validate if the itemId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(itemId)) {
      return res.status(400).json({ error: 'Invalid id parameter' });
    }

    // Delete the food item with the specified _id
    const deletedItem = await FoodItem.findByIdAndDelete(itemId);

    // If the item doesn't exist, return a 404 Not Found response
    if (!deletedItem) {
      return res.status(404).json({ error: 'Food item not found' });
    }

    // Return the deleted food item
    res.status(200).json(deletedItem);
  } catch (error) {
    // Handle any errors that occur during the process
    console.error('Error deleting food item:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

     ///////////////////////////////////////////////////////////////////
     //////////////////////////////////////////////////////////

     // Route to receive ID from another page
       // API to fetch user data
     app.get('/profile/:id', async (req, res) => {
       const userId = req.params.id;
       try {
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
      // Check if user is a homemaker
    app.get('/profile/:id/isHomemaker', async (req, res) => {
      const userId = req.params.id;
      try {
        const user = await User.findById(userId);
        if (!user) {
          return res.status(404).json({ error: 'User not found' });
        }
        res.json({ isHomemaker: user.isHomeMaker });
      } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ error: 'An error occurred while fetching user' });
      }
    });

     // API to update user data
     app.put('/profile/:id', async (req, res) => {
       const userId = req.params.id;
       const newData = req.body;
       try {
         await User.findByIdAndUpdate(userId, newData);
         res.send('User data updated successfully');
       } catch (error) {
         res.status(500).send(error.message);
       }
     });
     app.get('/profile/:id/availability', async (req, res) => {
       const userId = req.params.id;
       try {
         // Find the user by ID
         const user = await User.findById(userId);
         if (!user) {
           return res.status(404).json({ error: 'User not found' });
         }
         // Retrieve the availability status
         const availabilityStatus = user.isAvailable;
         // Return the availability status
         res.json({ isAvailable: availabilityStatus });
       } catch (error) {
         console.error('Error fetching availability status:', error);
         res.status(500).json({ error: 'An error occurred while fetching availability status' });
       }
     });
     // API to update availability
     app.put('/profile/:id/availability', async (req, res) => {
        const userId = new mongoose.Types.ObjectId(req.params.id);
        const { isAvailable } = req.body;
        try {
          // Find the user by ID
          const user = await User.findById(userId);
          if (!user) {
            return res.status(404).json({ error: 'User not found' });
          }
          // Update the availability
          user.isAvailable = !isAvailable;
          await user.save();
          // Fetch the updated availability status
          const updatedUser = await User.findById(userId);
          if (!updatedUser) {
            return res.status(404).json({ error: 'User not found after updating availability' });
          }
          // Return the updated user with the new availability status
          res.json({ message: 'Availability updated successfully', user: updatedUser });
        } catch (error) {
          console.error('Error updating availability:', error);
          res.status(500).json({ error: 'An error occurred while updating availability' });
        }
      });
     // API to delete account
     app.delete('/profile/:id', async (req, res) => {
       const userId = req.params.id;
       try {
         await User.findByIdAndDelete(userId);
         res.send('Account deleted successfully');
       } catch (error) {
         res.status(500).send(error.message);
       }
     });
     // Logout endpoint
     app.get('/logout', (req, res) => {
       // Clear session data here
       req.session.destroy((err) => {
         if (err) {
           console.error('Error destroying session:', err);
           res.status(500).json({ error: 'Internal server error' });
         } else {
           res.json({ message: 'Logout successful' });
         }
       });
     });
// Start the server
app.listen(port, () => {
  console.log(`Server is running on ${port}`);
});
