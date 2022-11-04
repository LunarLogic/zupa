import { FC, useEffect } from "react";
import { useNavigate } from "react-router-dom";

import { Logo } from "../../components/icons/Icons";
import { paths } from "../../utils/paths";

const PageNotFound: FC = () => {
  const navigate = useNavigate();

  useEffect(() => {
    navigate(paths.pageNotFound);
  }, []);

  return (
    <div className="not-found">
      <Logo className="not-found__logo" />
      <h1 className="not-found__heading">Strona, której szukasz, nie jest dostępna</h1>
      <p>
        Wygląda na to, że została przeniesiona lub usunięta. Prosimy spróbuj ponownie wprowadzić
        adres URL lub skorzystaj z menu nawigacyjnego, aby znaleźć potrzebną Ci informację.
      </p>
    </div>
  );
};

export default PageNotFound;
