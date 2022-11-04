import { FC, ReactNode } from "react";

interface PageHeaderProps {
  children?: ReactNode;
  heading?: string;
}

const PageHeader: FC<PageHeaderProps> = ({ heading, children }) => {
  return (
    <div className="page-header">
      <h1 className="page-header__title">{heading}</h1>
      {children}
    </div>
  );
};

export default PageHeader;
