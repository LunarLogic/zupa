import { FC, ReactNode } from "react";

import ScrollToTop from "../../../utils/scroll/ScrollToTop";
import Navigation from "../../molecules/Navigation/Navigation";
import Footer from "../Footer/Footer";

interface LayoutProps {
  children: ReactNode;
}

const Layout: FC<LayoutProps> = ({ children }) => {
  return (
    <div className="layout">
      <header className="layout__header">
        <Navigation />
      </header>
      <main className="layout__main-content">
        <ScrollToTop />
        {children}
      </main>
      <Footer />
    </div>
  );
};

export default Layout;
