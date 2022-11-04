import { ButtonHTMLAttributes, FC } from "react";

type ButtonProps = {
  variant: ButtonTypeEnum;
  children: React.ReactNode;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  className?: string;
  type?: ButtonHTMLAttributes<HTMLButtonElement>["type"];
};

export const enum ButtonTypeEnum {
  Primary = "primary",
  Secondary = "secondary",
  Rounded = "rounded",
  Icon = "icon",
  CategoryTile = "category-tile",
  Navigate = "navigate",
  Text = "text",
}

const Button: FC<ButtonProps> = ({ variant, children, onClick, className, type }) => {
  return (
    <button className={`button button--${variant} ${className}`} onClick={onClick} type={type}>
      {children}
    </button>
  );
};

export default Button;
