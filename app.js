const express = require('express');
const bodyParser = require('body-parser'); //?
const mongoose = require('mongoose');
const session = require('express-session'); //??
const { validationResult } = require('express-validator');
const bcryptjs = require('bcryptjs'); // compare between the plain password & the hashed
const bcrypt = require('bcrypt'); //hash for the password
const { ObjectId } = require('mongodb');
const app = express();
const port = 3000;
const crypto = require('crypto')
const { CronJob } = require('cron'); //??
const cors = require('cors');

// Generate a random key with 32 bytes (256 bits) length
const randomKey = crypto.randomBytes(32).toString('hex');
console.log('Random key:', randomKey);

// Middleware to initialize sessions
app.use(session({
  secret: randomKey,
  resave: false,
  saveUninitialized: true
}));
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
  // Hash the password
      const hashedPassword = await bcrypt.hash(password, 10); // 10 is the salt rounds
      // Create a new user object based on the request body
      const newUser = new User({
        firstName,
        lastName,
        phone,
        id,
        address,
        email,
        password : hashedPassword, // Store the hashed password,
         isHomeMaker: !!isHomeMaker,
         isAvailable: !!isAvailable
      });
   await newUser.save();
     // Return success response
     res.status(200).json({message: 'Registration successful', userId: newUser._id });
   } catch (error) {
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

app.get('/register/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const user = await User.findById(userId); // Assuming 'User' is your Mongoose model for users

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user); // Return user details
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

//////////////////////////////////////////////////////
/////////////////////////////////////////////////////
  const foodItemSchema = new mongoose.Schema({
      chefId: String,
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
        const { chefId, name, description, price, photo, category } = req.body; // Destructure chefId from the request body
        try {
          // Create a new food item with userId included
          const foodItem = new FoodItem({ chefId, name, description, price, photo, category });
          await foodItem.save();
          // Send response with the newly created food item including its id
          res.status(201).json({ id: foodItem._id, chefId, name, description, price, photo, category });
        } catch (error) {
          // Handle any errors that occur during the process
          console.error('Error saving food item:', error);
          res.status(500).json({ error: 'Internal server error' });
        }
      });

      app.get('/food-items', async (req, res) => {
           const { chefId } = req.query;
           try {
             const foodItems = await FoodItem.find({ chefId }); // Fetch food items from MongoDB where chefId matches
             console.log('Fetched food items:', foodItems);
             console.log('Fetched food items:', chefId);
             res.json(foodItems);
           } catch (error) {
             console.error('Error fetching food items:', error);
             res.status(500).json({ error: 'Internal server error' });
           }
         });

      app.put('/food-items/:id', async (req, res) => {
               try {
                   const { id } = req.params;
                   const updatedItem = req.body;

                   const result = await FoodItem.findByIdAndUpdate(id, updatedItem, { new: true });

                   if (!result) {
                       return res.status(404).json({ error: 'Food item not found' });
                   }

                   res.status(200).json(result);
               } catch (error) {
                   console.error('Error updating food item:', error);
                   res.status(500).json({ error: 'Internal server error' });
               }
           });

      app.delete('/food-items/:id', async (req, res) => {
        try {
          const itemId = req.params.id; // Extract the id parameter from the request URL
          console.log('Received id:', itemId); // Log the id value
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
     ///////////////////Loooooooooooooooooooooooooooooooooooooooooooooooogin//////////////////////////////////////////////////////////// Handle login requests

  app.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid email or password' });
      }
      const storedPassword = user.password;
      const isPasswordValid = await bcryptjs.compare(password, storedPassword);
      if (isPasswordValid) {
        res.status(200).json({ success: true, message: 'Login successful', userId: user._id });
      } else {
        res.status(401).json({ success: false, message: 'Invalid email or password' });
      }
    } catch (error) {
      console.error('Error during login:', error);
      res.status(500).json({ success: false, message: 'Internal server error' });
    }
  });
   ///////////////////Loooooooooooooooooooooooooooooooooooooooooooooooogin///////////////////////////////////////////////////////////

   /////////////////////////////////// API to fetch user data
    /////////////////////////////////// API to fetch user data
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
   //////////////////////////////////////// Check if user is a homemaker
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

   ///////////////////////////////////////// API to update user data
   app.put('/profile/:id', async (req, res) => {
     const userId = req.params.id;
     const newData = req.body;
     try {
       await User.findByIdAndUpdate(userId, newData);
       // Fetch the updated user data from the database
       const updatedUser = await User.findById(userId);
       res.send('User data updated successfully');
     } catch (error) {
       res.status(500).send(error.message);
     }
   });
   ///////////////////////////////////////// get availability status
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

   ////////////////////////////// API to update availability
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
   app.use(cors());

   app.put('/changeEmail', async (req, res) => {
     const { userId, currentEmail, newEmail } = req.body;

     // Find the user by userId
     const user = await User.findById(userId);
     if (!user) {
       return res.status(404).json({ message: "User not found" });
     }

     // Check if the current email matches the one stored in the database
     if (user.email !== currentEmail) {
       return res.status(400).json({ message: "Current email is incorrect" });
     }

     // Validate the new email format
     if (!newEmail.endsWith('@gmail.com')) {
       return res.status(400).json({ message: "New email must be a Gmail address" });
     }

     try {
       // Check if the new email is already in use by another user
       const existingUser = await User.findOne({ email: newEmail });
       if (existingUser && existingUser._id.toString() !== userId) {
         return res.status(400).json({ message: "Email is already in use by another user" });
       }

       // Update the user's email
       user.email = newEmail;
       await user.save();
       // Fetch the updated user data from the database
       const updatedUser = await User.findById(userId);
       res.status(200).json({ message: "Email updated successfully" });
     } catch (error) {
       res.status(500).json({ message: "Failed to update email" });
     }
   });
   module.exports = app;

   // POST to change password
   app.put('/changePassword', async (req, res) => {
     const { userId, currentPassword, newPassword } = req.body;

     // Find the user by userId
     const user = await User.findById(userId);
     if (!user) {
       return res.status(404).json({ message: "User not found" });
     }

     // Check if the current password matches the one stored in the database
     const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
     if (!isPasswordValid) {
       return res.status(400).json({ message: "Current password is incorrect" });
     }

     // Hash the new password
     const hashedPassword = await bcrypt.hash(newPassword, 10);

     // Update the user's password
     try {
       user.password = hashedPassword;
       await user.save();
       // Fetch the updated user data from the database
       const updatedUser = await User.findById(userId);
       res.status(200).json({ message: "Password updated successfully" });
     } catch (error) {
       res.status(500).json({ message: "Failed to update password" });
     }
   });

   module.exports = app;

   ////////////////////////////////  API to delete account
   app.delete('/profile/:id', async (req, res) => {
     const userId = req.params.id;
     try {
       // Delete food items associated with the user
       await FoodItem.deleteMany({ chefId: userId });

       await User.findByIdAndDelete(userId);
       res.send('Account deleted successfully');
     } catch (error) {
       res.status(500).send(error.message);
     }
   });
   //////////////////////////////////////////    Logout endpoint
   app.post('/logout', (req, res) => {
     // Clear session data here
     req.session.destroy((err) => {
       if (err) {
         console.error('Error destroying session:', err);
         res.status(500).json({ error: 'Internal server error' });
       } else {
         res.json({ message: 'Logout successful' });
         console.log("session destroied");
       }
     });
   });
    ///////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////

     // Define the schema for cart items
        const cartItemSchema = new mongoose.Schema({
          userId: { type: String, required: true },
          foodItemId: { type: String, required: true },
          quantity: { type: Number, required: true },
        });
        // Define the model for cart items
        const CartItem = mongoose.model('CartItem', cartItemSchema);
        // Create an Item in the Cart with input validation and error handling
        app.post('/cart', async (req, res) => {
              const { userId, foodItemId ,quantity} = req.body;

              try {
                // Validate input
                console.log('userId', userId);
                console.log('foodItemId', foodItemId);
                console.log('quantity', quantity);
                // Check if the same item already exists in the cart
           const existingCartItem = await CartItem.findOne({ userId, foodItemId });
           if (existingCartItem) {
          // If the same item exists, increase its quantity
          existingCartItem.quantity +=parseInt(quantity);; // Increment by 1
          await existingCartItem.save();
          console.log('Item quantity updated in the cart');
          return res.status(200).json(existingCartItem);
        }// If the item is not in the cart, add it with the specified quantity
                // Create a new cart item
                const newCartItem = await CartItem.create({ userId, foodItemId, quantity });
                console.log('New item added to the cart');
                res.status(201).json(newCartItem);
              } catch (error) {
                console.error('Error creating cart item:', error);
                res.status(500).json({ error: 'Internal server error' });
              }
            });

        // Read Items in the Cart
      app.get('/cart', async (req, res) => {
        try {
          const { userId } = req.query;
          // Assuming you have a CartItem model and you want to populate the foodItem field with the FoodItem details
          const cartItems = await CartItem.find({ userId }).populate('foodItemId'); // Assuming the field is named foodItemId
          console.log('Cart Items:', cartItems); // Add this line to print cart items
          res.json(cartItems);
        } catch (error) {
          console.error('Error fetching cart items:', error);
          res.status(500).json({ error: 'Internal server error' });
        }
      });
      app.get('/food-items/:foodItemId', async (req, res) => {
        try {
          const foodItemId = req.params.foodItemId;
          const foodItem = await FoodItem.findById(foodItemId);
          if (!foodItem) {
            return res.status(404).json({ error: 'Food item not found' });
          }
          // Return the food item as JSON response
          console.log('foodItemId :' , foodItemId)
          res.json(foodItem);
        } catch (error) {
          console.error('Error fetching food item:', error);
          res.status(500).json({ error: 'Internal server error' });
        }
      });
        // Update an Item in the Cart with input validation and error handling
        app.put('/cart/:id', async (req, res) => {
          const id = req.params.id;
          const { quantity } = req.body;

          // Validate input
          if (!quantity || typeof quantity !== 'number' || quantity <= 0) {
            return res.status(400).json({ error: 'Invalid quantity' });
          }
          try {
            // Find the cart item by ID and update its quantity by incrementing by 1
            const updatedCartItem = await CartItem.findByIdAndUpdate(id,  { $inc: { quantity: 1 } }, { new: true });
            if (!updatedCartItem) {
              return res.status(404).json({ error: 'Cart item not found' });
            }
            console.log('Updated cart item:', updatedCartItem);
            console.log('puuuuuut');
            console.log('id :' , id);
             console.log('quantity incremented by 1');
            res.json(updatedCartItem);
          } catch (error) {
            console.error('Error updating cart item:', error);
            res.status(500).json({ error: 'Internal server error' });
          }
        });// Increase quantity of an Item in the Cart
        app.patch('/cart/increase/:id', async (req, res) => {
          const id = req.params.id;
          try {
            // Find the cart item by ID and increase its quantity by 1
            const updatedCartItem = await CartItem.findByIdAndUpdate(id, { $inc: { quantity: 1 } }, { new: true });
            if (!updatedCartItem) {
              return res.status(404).json({ error: 'Cart item not found' });
            }
            console.log('Increased cart item quantity:', updatedCartItem);
            res.json(updatedCartItem);
          } catch (error) {
            console.error('Error increasing cart item quantity:', error);
            res.status(500).json({ error: 'Internal server error' });
          }
        });
        // decrease quantity of an Item in the Cart
        app.patch('/cart/decrease/:id', async (req, res) => {
          const id = req.params.id;
          try {
            // Find the cart item by ID and decrease its quantity by 1
            const updatedCartItem = await CartItem.findByIdAndUpdate(id, { $inc: { quantity: -1 } }, { new: true });
            if (!updatedCartItem) {
              return res.status(404).json({ error: 'Cart item not found' });
            }
            // If quantity becomes less than 1, delete the item from the cart and database
            if (updatedCartItem.quantity < 1) {
              await CartItem.findByIdAndDelete(id);
              console.log('Cart item deleted due to quantity less than 1:', updatedCartItem);
              return res.json({ message: 'Cart item deleted successfully' });
            }
            console.log('Decreased cart item quantity:', updatedCartItem);
            res.json(updatedCartItem);
          } catch (error) {
            console.error('Error decreasing cart item quantity:', error);
            res.status(500).json({ error: 'Internal server error' });
          }
        });
        // Delete an Item from the Cart
        app.delete('/cart/:id', async (req, res) => {
          const cartItemId = req.params.id;
          try {
            // Find the cart item by ID and delete it
            const deletedCartItem = await CartItem.findByIdAndDelete(cartItemId);

            if (!deletedCartItem) {
              return res.status(404).json({ error: 'Cart item not found' });
            }

            res.json({ message: 'Cart item deleted successfully' });
          } catch (error) {
            console.error('Error deleting cart item:', error);
            res.status(500).json({ error: 'Internal server error' });
          }
        });
    /////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////

    const orderSchema = new mongoose.Schema({
         chefId: { type: String, required: true },
         userId: { type: String, required: true },
         foodItems: [{
           foodItemId: { type: String, required: true },
           quantity: { type: Number, required: true }
         }],
         status: { type: String, enum: ['pending', 'accepted', 'declined'], default: 'pending' }
       });

      const Order = mongoose.model('Order', orderSchema);

      app.post('/orders', async (req, res) => {
        const { userId, chefId, foodItems } = req.body;

        try {
          // Create a new order document
          const order = await Order.create({ userId, chefId, foodItems });

          // Extract the food item IDs from the foodItems array
          const foodItemIds = foodItems.map(item => item.foodItemId);

          // Delete corresponding cart items based on foodItemId and userId
          await CartItem.deleteMany({ userId, foodItemId: { $in: foodItemIds } });

          console.log('Order created:', order); // Print created order
          res.status(201).json(order);
        } catch (error) {
          console.error('Error creating order:', error); // Print error if any
          res.status(400).json({ error: error.message });
        }
      });

      // Endpoint for fetching pending orders for a chef
      app.get('/orders/:chefId/pending', async (req, res) => {
        try {
          const chefId = req.params.chefId;
          console.log('Fetching pending orders for chefId:', chefId); // Print statement added
          const pendingOrders = await Order.find({ chefId, status: 'pending' }).populate('userId').populate('foodItems.foodItemId');
          res.json(pendingOrders);
        } catch (error) {
          console.error('Error fetching pending orders:', error); // Print statement added
          res.status(500).json({ error: error.message });
        }
      });

   //
       // Endpoint for fetching processing orders for a chef
            app.get('/orders/:chefId/processing', async (req, res) => {
              try {
                const chefId = req.params.chefId;
                console.log('Fetching pending orders for chefId:', chefId); // Print statement added
                const pendingOrders = await Order.find({ chefId, status: 'accepted' }).populate('userId').populate('foodItems.foodItemId');
                res.json(pendingOrders);
              } catch (error) {
                console.error('Error fetching processing orders:', error); // Print statement added
                res.status(500).json({ error: error.message });
              }
            });
            // Endpoint for fetching finished orders for a chef
            app.get('/orders/:chefId/finished', async (req, res) => {
              try {
                const chefId = req.params.chefId;
                console.log('Fetching pending orders for chefId:', chefId); // Print statement added
                const pendingOrders = await Order.find({ chefId, status: 'finished' }).populate('userId').populate('foodItems.foodItemId');
                res.json(pendingOrders);
              } catch (error) {
                console.error('Error fetching processing orders:', error); // Print statement added
                res.status(500).json({ error: error.message });
              }
            });
            // Endpoint for fetching current orders for a user
                app.get('/orders/:userId/accepted', async (req, res) => {
              try {
                const userId = req.params.userId;
                console.log('Fetching current orders for userId:', userId); // Print statement added
                const currentOrders = await Order.find({ userId, status: 'accepted' }).populate('chefId').populate('foodItems.foodItemId');
                res.json(currentOrders);
              } catch (error) {
                console.error('Error fetching current orders:', error); // Print statement added
                res.status(500).json({ error: error.message });
              }
            });
            // Endpoint for fetching previous orders for a user
            app.get('/orders/:userId/previous', async (req, res) => {
              try {
                const userId = req.params.userId;
                console.log('Fetching previous orders for userId:', userId); // Print statement added
                const previousOrders = await Order.find({ userId, status: 'finished' }).populate('chefId').populate('foodItems.foodItemId');
                res.json(previousOrders);
              } catch (error) {
                console.error('Error fetching previous orders:', error); // Print statement added
                res.status(500).json({ error: error.message });
              }
            });

            // Endpoint for updating order status
            app.put('/orders/:orderId', async (req, res) => {
              try {
                const orderId = req.params.orderId;
                const { status } = req.body;
                const updatedOrder = await Order.findByIdAndUpdate(orderId, { status }, { new: true });
                // Fetch the user's ID associated with the order
                    const userId = updatedOrder.userId;

   res.json(updatedOrder);
          } catch (error) {
            res.status(400).json({ error: error.message });
          }
        });
   module.exports = app;
       // Start the server
          app.listen(port, () => {
            console.log(`Server is running on ${port}`);
          });