import express from "express";
import session from "express-session";
import dotenv from "dotenv";
import passport from "./passport";

dotenv.config();

const app = express();
const port = process.env.PORT ? Number(process.env.PORT) : 3000;

app.use(
  session({
    secret: process.env.SESSION_SECRET || "dev-secret",
    resave: false,
    saveUninitialized: false
  })
);

app.use(passport.initialize());
app.use(passport.session());

app.get("/", (req, res) => {
  res.send(`<a href="/auth/github">Sign in with GitHub</a>`);
});

app.get("/auth/github", passport.authenticate("github", { scope: ["user:email"] }));

app.get(
  "/auth/github/callback",
  passport.authenticate("github", { failureRedirect: "/" }),
  (req, res) => {
    res.redirect("/profile");
  }
);

app.get("/profile", (req, res) => {
  if (!req.user) return res.redirect("/");
  // @ts-ignore
  res.json(req.user);
});

app.get("/logout", (req, res) => {
  req.logout(() => {});
  res.redirect("/");
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
