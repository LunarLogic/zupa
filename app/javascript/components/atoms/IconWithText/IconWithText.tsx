import { FC } from "react";

interface IconWithTextProps {
  text: string;
  icon: JSX.Element;
}

const IconWithText: FC<IconWithTextProps> = ({ text, icon }) => {
  return (
    <div className={"icon-with-text"}>
      <div className="icon-with-text__icon">{icon}</div>
      <span className="icon-with-text__text">{text}</span>
    </div>
  );
};

export default IconWithText;
