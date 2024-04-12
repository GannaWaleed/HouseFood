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

  const foodItemSchema = new mongoose.Schema({
     name: String,
     description: String,
     price: String,
     photo: String,
     category: String
   });

   const FoodItem = mongoose.model('FoodItem', foodItemSchema);

   app.use(bodyParser.json());

   app.post('/food-items', async (req, res) => {
     const {  name, description, price, photo,category } = req.body;
      try {
          const foodItem = new FoodItem({ name, description, price, photo, category });
          await foodItem.save();
          // Send response with the newly created food item including its id
          res.status(201).json({ id: foodItem._id, name, description, price, photo, category });
        } catch (error) {
         // Handle any errors that occur during the process
         console.error('Error saving food item:', error);
         res.status(500).json({ error: 'Internal server error' });
       }
     });
   // READ all food items
   // READ all food items
   app.get('/food-items', async (req, res) => {
     try {
       const foodItems = await FoodItem.find();
       res.status(200).json(foodItems);
     } catch (error) {
       console.error('Error reading food items:', error);
       res.status(500).json({ error: 'Internal server error' });
     }
   });


   // READ a single food item by ID
   app.get('/food-items/:id', async (req, res) => {
     try {
       const foodItem = await FoodItem.findById(req.params.id);
       if (!foodItem) {
         return res.status(404).json({ error: 'Food item not found' });
       }
       res.status(200).json(foodItem);
     } catch (error) {
       console.error('Error reading food item:', error);
       res.status(500).json({ error: 'Internal server error' });
     }
   });

   // UPDATE a food item by ID
   // UPDATE a food item by ID
   const { validationResult } = require('express-validator');

   app.put('/food-items/:id', async (req, res) => {
     try {
         // Update the food item with the specified _id
         const updatedItem = await FoodItem.findByIdAndUpdate(req.params.id, req.body, { new: true });

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

   // DELETE a food item by ID
   app.delete('/food-items/:id', async (req, res) => {
     try {
     const itemId = req.params.id; // Extract the id parameter from the request URL
         console.log('Received id:', itemId); // Log the id value

         // Add a check to validate the presence of the id parameter
         if (!itemId) {
           return res.status(400).json({ error: 'Missing id parameter' });
         }
         // Delete the food item with the specified _id
         const deletedItem = await FoodItem.findByIdAndDelete(req.params.id);

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
// Start the server
app.listen(port, () => {
  console.log(`Server is running on ${port}`);
});
