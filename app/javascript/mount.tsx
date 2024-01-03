import React, {StrictMode} from 'react';
import { createRoot } from "react-dom/client";
import '@hotwired/turbo-rails'

type Components = Record<string, React.ElementType>;

export default function mount(components: Components): void {
    document.addEventListener("turbo:load", () => {
        const mountPoints = document.querySelectorAll("[data-react-component]");
        mountPoints.forEach((mountPoint) => {
            const { dataset } = mountPoint as HTMLElement;
            const componentName = dataset.reactComponent;
            if (componentName) {
                const Component = components[componentName];
                if (Component) {
                    const props = JSON.parse(dataset.props as string);
                    const root = createRoot(mountPoint);
                    root.render(
                        <StrictMode>
                            <Component {...props} />
                        </StrictMode>
                    );
                } else {
                    console.warn(
                        "WARNING: No component found for: ",
                        dataset.reactComponent,
                        components
                    );
                }
            }
        });
    });
}
