import passport from "passport";
import { Strategy as GitHubStrategy } from "passport-github2";
import dotenv from "dotenv";
dotenv.config();

const clientID = process.env.GITHUB_CLIENT_ID || "";
const clientSecret = process.env.GITHUB_CLIENT_SECRET || "";
const callbackURL = process.env.CALLBACK_URL || "http://localhost:3000/auth/github/callback";

passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((obj: any, done) => {
  done(null, obj);
});

passport.use(
  new GitHubStrategy(
    { clientID, clientSecret, callbackURL },
    (accessToken, refreshToken, profile, done) => {
      // Minimal: pass profile through for testing
      const user = { profile, accessToken };
      return done(null, user);
    }
  )
);

export default passport;
