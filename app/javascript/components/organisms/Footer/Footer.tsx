import { Heart } from "../../icons/Icons";
import Smileys from "../../molecules/Smileys/Smileys";

const Footer = () => {
  return (
    <footer className="footer">
      <Smileys />
      <div className="footer__text">
        <span>Zupa na Plantach</span>
        <Heart className="footer__heart-icon" />
        <span>Lunar Logic</span>
      </div>
    </footer>
  );
};

export default Footer;
