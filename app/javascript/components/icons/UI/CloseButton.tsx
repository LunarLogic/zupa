type CloseButtonProps = {
  color?: string;
};

export const CloseButton = ({ color }: CloseButtonProps) => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path
      d="M6 18L18 6M6 6L18 18"
      stroke={color || "#585858"}
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);
