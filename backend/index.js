const express = require("express");
const path = require("path");
const app = express();
const port = 3000;

// --- Middleware ---

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// --- API Endpoints ---

app.get("/", (req, res) => {
  res.send("<h1>Hello</h1>");
});

// This endpoint sends the list of categories
app.get("/api/categories", (req, res) => {
  console.log("Request received for /api/categories");

  const categories = [
    {
      id: 1,
      title: "Travel & Stay",
      imageUrl: "/images/travel.jpg",
    },
    {
      id: 2,
      title: "Banquets & Venues",
      imageUrl: "/images/banquet.jpg",
    },
    {
      id: 3,
      title: "Retail stores & Shops",
      imageUrl: "/images/retail.jpg",
    },
  ];

  res.json(categories);
});
//made by - neetish bamotra
// This endpoint receives the form data
app.post("/api/banquet-request", (req, res) => {
  const formData = req.body;

  console.log("--- New Banquet Request Received ---");
  console.log(formData);
  console.log("------------------------------------");

  res.status(201).json({
    message: "Request received successfully!",
    dataReceived: formData,
  });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
