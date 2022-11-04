import { ChangeEvent, FC } from "react";

interface TextAreaProps {
  label: string;
  id: string;
  name: string;
  value: string;
  placeholder?: string;
  onChange?: (event: ChangeEvent<HTMLTextAreaElement>) => void;
}

const TextArea: FC<TextAreaProps> = ({ label, id, name, value, placeholder, onChange }) => {
  return (
    <label className="textarea-label">
      {label}
      <textarea
        id={id}
        name={name}
        className="textarea-field"
        value={value}
        placeholder={placeholder}
        onChange={onChange}
        aria-label={label}
      />
    </label>
  );
};

export default TextArea;
