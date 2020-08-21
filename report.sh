#! /bin/zsh

if which node > /dev/null
then
    echo "Node is installed!"
else
    echo "You need to install node first: brew install node."
    exit 1
fi

## Cleanup old build
rm -rf build
mkdir -p build

## Create TestReport
xcodebuild build-for-testing -workspace NHS-COVID-19.xcworkspace -scheme "NHS-COVID-19-Internal" -destination "name=iPhone 11 Pro"
xcrun simctl boot "iPhone 11 Pro"
xcodebuild test-without-building -workspace NHS-COVID-19.xcworkspace -scheme "NHS-COVID-19-Internal" -destination "name=iPhone 11 Pro" -testPlan ReportTests

## Create AppReport
pushd Reporting
swift run Reporter workspace ../NHS-COVID-19.xcworkspace --scheme "NHS-COVID-19" --method archive --output ../AppReport
popd

## Generate documentation
git clone https://github.com/nhsx/COVID-19-app-documentation-reporting.git doc_gen
pushd doc_gen
git checkout iOS-reporting-but-small
npm install
npm run build:preview ../
popd
