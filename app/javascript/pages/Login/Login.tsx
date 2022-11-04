import Cookies from "js-cookie";
import { ChangeEvent, FC, FormEvent, useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { z } from "zod";

import authenticate from "../../api/authenticate";
import Button, { ButtonTypeEnum } from "../../components/atoms/Button/Button";
import Input from "../../components/atoms/Input/Input";
import { LoginFormSchema } from "../../components/atoms/ValidationSchemas/formValidation";
import { LogoNoText } from "../../components/icons/Icons";
import { failureMsg } from "../../components/molecules/Toast/toastMessages";
import { AppContext } from "../../context/AppContext";
import { useAuth } from "../../hooks/useAuth";
import { useTranslation } from "../../hooks/useTranslation";
import { paths } from "../../utils/paths";

const Login: FC = () => {
  const { login, isAuthenticated } = useAuth();
  const t = useTranslation();
  const [name, setName] = useState("");
  const [code, setCode] = useState("");
  const [errors, setErrors] = useState({ name: "", code: "" });
  const navigate = useNavigate();

  const { addToast } = useContext(AppContext);

  useEffect(() => {
    if (isAuthenticated) {
      navigate(paths.search);
    }
  }, [isAuthenticated, navigate]);

  useEffect(() => {
    const userName = Cookies.get("userName");
    if (userName) {
      setName(userName);
    }
  }, []);

  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    setName(event.target.value);
    setErrors({ ...errors, name: "" });
  };

  const handleCodeChange = (event: ChangeEvent<HTMLInputElement>) => {
    setCode(event.target.value);
    setErrors({ ...errors, code: "" });
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    try {
      const values = LoginFormSchema.parse({ name, code });
      if (await authenticate(values)) {
        login(values);
        navigate(paths.search);
        Cookies.set("userName", values.name, { expires: 365, secure: true, sameSite: "strict" });
      } else {
        setErrors({ ...errors, code: "Nieprawidłowy kod dostępu" });
      }
    } catch (error) {
      if (error instanceof z.ZodError) {
        setErrors({
          name: error?.issues?.[0]?.message ?? "",
          code: error?.issues?.[1]?.message ?? "",
        });
      }
      addToast("error", failureMsg);
    }
  };

  return (
    <div className="login">
      <div className="login__logo-container">
        <LogoNoText title="Logo" className="login__logo-icon" />
      </div>

      <h1 className="login__heading">{t.loginPage.greeting}</h1>

      <p className="login__secondary-text">{t.loginPage.description}</p>

      <form onSubmit={handleSubmit} className="login__form" role="form">
        <Input
          label={t.loginPage.nameField}
          id="name"
          name="name"
          value={name}
          onChange={handleNameChange}
          errorMessage={errors.name ? errors.name : null}
        />
        <Input
          label={t.loginPage.codeField}
          id="code"
          name="code"
          value={code}
          onChange={handleCodeChange}
          errorMessage={errors.code ? errors.code : null}
        />

        <Button className="login__form-button" variant={ButtonTypeEnum.Primary}>
          {t.loginPage.enterButton}
        </Button>
      </form>
    </div>
  );
};

export default Login;
