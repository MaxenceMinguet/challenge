const cors = require("cors");
const { env } = require("./env");

const corsPolicy = () => cors({
  origin: env.UI_URL,
  methods: ["GET","POST","PUT","DELETE","OPTIONS"],
  allowedHeaders: ["Content-Type","Accept","Origin","X-CSRF-TOKEN","Authorization"],
  credentials: true,
  preflightContinue: false,
  optionsSuccessStatus: 204
});

module.exports = { corsPolicy };
