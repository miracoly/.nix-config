_: {
  services.espanso = {
    enable = true;
    matches = {
      ai-prompts = {
        matches = [
          {
            trigger = ":ai.test.jest";
            label = "AI > Test > Jest";
            form = ''
              Please create Jest tests for the file [[filename]].
              Follow best practices and conventions.
              Do not add any comments.
              Use `const user = userEvent.setup();` for interacting with components if necessary.

              Create the following tests:
              - $|$

              Mock the following imports. Do not mock anything else.
              -
            '';
          }
        ];
      };
    };
  };
}
