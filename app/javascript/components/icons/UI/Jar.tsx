interface JarProps {
  className?: string;
}

export const Jar = ({ className }: JarProps) => (
  <svg
    width="23"
    height="24"
    viewBox="0 0 23 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className={className}
  >
    <rect
      x="4.75"
      y="5.75"
      width="13.5"
      height="15.5"
      rx="2.25"
      stroke="#191919"
      strokeWidth="1.2"
    />
    <rect x="4.75" y="10.75" width="13.5" height="7.5" stroke="#191919" strokeWidth="1.2" />
    <rect
      x="5.75"
      y="2.25"
      width="11.5"
      height="3.5"
      rx="1.25"
      stroke="#191919"
      strokeWidth="1.2"
    />
  </svg>
);
