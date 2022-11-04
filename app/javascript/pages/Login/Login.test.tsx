import userEvent from "@testing-library/user-event";

import { AppProvider } from "../../context/AppProvider";
import { fireEvent, render, screen } from "../../setupTests";
import LoginPage from "./Login";

describe("<LoginPage />", () => {
  const user = userEvent.setup();

  it("displays inputted name value", async () => {
    render(
      <AppProvider>
        <LoginPage />
      </AppProvider>
    );

    const nameInput = (await screen.findByLabelText("Imię i Nazwisko")) as HTMLInputElement;
    expect(nameInput.value).toBe("");

    await user.type(nameInput, "John Doe");
    expect(nameInput.value).toBe("John Doe");
  });

  it("displays inputted code value", async () => {
    render(
      <AppProvider>
        <LoginPage />
      </AppProvider>
    );

    const codeInput = (await screen.findByLabelText("Kod")) as HTMLInputElement;
    expect(codeInput.value).toBe("");

    await user.type(codeInput, "1234");
    expect(codeInput.value).toBe("1234");
  });

  it("submits the form", async () => {
    render(
      <AppProvider>
        <LoginPage />
      </AppProvider>
    );
    const handleOnSubmitMock = jest.fn();
    screen.getByRole("form").onsubmit = handleOnSubmitMock;

    fireEvent.click(screen.getByRole("button"));
    expect(handleOnSubmitMock).toHaveBeenCalled();
  });
});
