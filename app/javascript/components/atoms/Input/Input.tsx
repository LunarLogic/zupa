import { ChangeEvent, FC, FocusEvent, FormEvent, MouseEvent, useRef } from "react";

import { CloseButton } from "../../icons/Icons";
import { DropdownIcon } from "../../icons/Icons";

interface InputProps {
  label: string;
  id: string;
  name: string;
  value: string;
  type?: string;
  list?: string;
  placeholder?: string;
  className?: string;
  readOnly?: boolean;
  errorMessage?: string | null;
  disabled?: boolean;
  autoComplete?: string;
  clearButton?: boolean;
  onChange?: (event: ChangeEvent<HTMLInputElement>) => void;
  onInput?: (event: FormEvent<HTMLInputElement>) => void;
  onClick?: (event: MouseEvent<HTMLInputElement>) => void;
  onBlur?: (event: FocusEvent<HTMLInputElement>) => void;
}

const Input: FC<InputProps> = ({
  label,
  type,
  id,
  name,
  value,
  list,
  placeholder,
  className,
  readOnly,
  errorMessage,
  disabled,
  clearButton = false,
  autoComplete = "off",
  onChange,
  onInput,
  onClick,
  onBlur,
}) => {
  const inputRef = useRef<HTMLInputElement>(null);

  const handleClearButtonClick = () => {
    onChange && onChange({ target: { value: "" } } as ChangeEvent<HTMLInputElement>);
    if (inputRef.current) {
      inputRef.current.value = "";
      inputRef.current.focus();
    }
  };

  const shouldShowClearButton = clearButton && value !== "";

  return (
    <label className="input-label">
      {label}
      <div className="input-field-wrapper">
        <input
          type={type}
          id={id}
          aria-label={label}
          name={name}
          list={list}
          className={`input-field ${className} ${errorMessage ? "input-field--error" : ""}`}
          value={value}
          placeholder={placeholder}
          readOnly={readOnly}
          disabled={disabled}
          autoComplete={autoComplete}
          onInput={onInput}
          onClick={onClick}
          onChange={(event) => {
            onChange && onChange(event);
          }}
          onBlur={onBlur}
        />
        {type === "search" && (
          <div className="input-field__dropdown-icon">
            <DropdownIcon />
          </div>
        )}
        {shouldShowClearButton && (
          <div className="input-field__clear-button" onClick={handleClearButtonClick}>
            <CloseButton />
          </div>
        )}
      </div>
      {errorMessage && <span className="input-field__error-message">{errorMessage}</span>}
    </label>
  );
};

export default Input;
