/** @jest-environment jsdom */

import { fireEvent, render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import { afterEach, beforeEach, describe, expect, it, jest } from "@jest/globals";
import * as React from "react";
import WithDebounce from "../src/utils/WithDebounce";

describe("WithDebounce", () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it("updates immediately and delays the change callback", () => {
    const onChange = jest.fn();

    render(
      <WithDebounce
        component={props => <input {...props} />}
        onChange={onChange}
        value="initial"
        debounceTimeout={500}
      />
    );

    const input = screen.getByRole("textbox");
    fireEvent.change(input, { target: { value: "updated" } });

    expect((input as HTMLInputElement).value).toBe("updated");
    expect(onChange).not.toHaveBeenCalled();

    jest.advanceTimersByTime(499);
    expect(onChange).not.toHaveBeenCalled();

    jest.advanceTimersByTime(1);
    expect(onChange).toHaveBeenCalledTimes(1);
  });

  it("synchronizes when the parent value changes", () => {
    const onChange = jest.fn();
    const { rerender } = render(
      <WithDebounce
        component={props => <input {...props} />}
        onChange={onChange}
        value="initial"
      />
    );

    const input = screen.getByRole("textbox");
    fireEvent.change(input, { target: { value: "local edit" } });
    expect((input as HTMLInputElement).value).toBe("local edit");

    rerender(
      <WithDebounce
        component={props => <input {...props} />}
        onChange={onChange}
        value="from parent"
      />
    );

    expect((input as HTMLInputElement).value).toBe("from parent");
  });

  it("does not access React's reserved key prop", () => {
    const consoleError = jest
      .spyOn(console, "error")
      .mockImplementation(() => undefined);

    render(
      <WithDebounce
        key="search-input"
        component={props => <input {...props} />}
        onChange={jest.fn()}
      />
    );

    expect(consoleError).not.toHaveBeenCalled();
    consoleError.mockRestore();
  });
});
