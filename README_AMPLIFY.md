Amplify DataStore setup (Flutter)

1. Install Amplify CLI (if not installed):

```powershell
npm install -g @aws-amplify/cli
amplify configure
```

If the global CLI fails, use the `npx` fallback:

```powershell
npx @aws-amplify/cli configure
```

2. Initialize Amplify in your project root:

```powershell
cd <project-root>
npx @aws-amplify/cli init
```

If the global `amplify` command still fails, continue using `npx @aws-amplify/cli`.

3. Add a GraphQL API with DataStore enabled:

```powershell
npx @aws-amplify/cli add api
# Choose: GraphQL, Answer "Yes" when asked about DataStore
```

4. Edit the generated GraphQL schema (`amplify/backend/api/<api-name>/schema.graphql`).

A simple Savings model example:

```graphql
type Saving @model {
  id: ID!
  title: String!
  amount: Float!
  date: AWSDateTime
  category: String
  note: String
}
```

5. Push backend and generate models:

```powershell
npx @aws-amplify/cli push --yes
npx @aws-amplify/cli codegen models
```

6. Add Flutter packages (run from project root):

```powershell
flutter pub add amplify_flutter
flutter pub add amplify_datastore
flutter pub add amplify_api
flutter pub add amplify_auth_cognito
```

7. In your Flutter app, import the generated `models/ModelProvider.dart` and
   call `AmplifyService.instance.configure()` early in app startup (for example
   in `main()` before `runApp`).

Notes:
- The CLI generates `amplifyconfiguration.dart` and the `models/` folder used
  by the Flutter plugins. Keep those generated files under version control.
- For auth-enabled sync, configure Cognito via `amplify add auth`.
