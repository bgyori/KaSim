/*jshint esversion: 6*/
class SnapLayout {
    constructor(snapshot, dimension, margin) {
        this.snapshot = snapshot;
        this.dimension = dimension;
        this.margin = margin ||
            { top: 10, right: 10,
            bottom: 10, left: 10 };
        
    }
}


class Snapshot {
    constructor(id) {
        this.id = "#"+id;
    }

    setData(response) {
        let snapshot = this;
        let root = d3.select(this.id);
        snapshot.data = new DataWareHouse(JSON.parse(response));
            snapshot.clearData();
            let margin = { top: 0, right: 10,
            bottom: 10, left: 10 };
            /* multiplying by a factor to account for flex display */     
            let w = d3.select("#snapshot-map-display").node().getBoundingClientRect().width * 5/6 - margin.left - margin.right;   
            let h = d3.select("#snapshot-map-display").node().getBoundingClientRect().height - margin.top - margin.bottom;

            if (snapshot.data) {
                let layout = new SnapLayout(snapshot, new Dimension(w, h), margin);
                let renderer = new SnapRender(root, layout);
                renderer.render();
            }        
    }

    clearData() {
        d3.select(this.id).selectAll("svg").remove();
        d3.select(this.id).selectAll("div").remove();
        d3.selectAll(".snap-tooltip").remove();

    }

}

class SnapRender {
    constructor(root, layout) {
        let renderer = this;
        this.root = root;
        let width = layout.dimension.width;
        let height = layout.dimension.height;
        this.layout = layout;

        let svgWidth = width +
                            this.layout.margin.left +
                            this.layout.margin.right;
        let svgHeight = height +
                            this.layout.margin.top +
                            this.layout.margin.bottom ;
  
        let container = this.container = this.root
            .append("div")
            .classed("render-container flex-content", true)
            .style("position", "relative")
            .append("div")
            .classed("snapshot-container", true)
            .append("svg")
            .attr("class", "svg-group")
            .attr("id", "map-container")
            .attr("preserveAspectRatio", "xMinYMin meet")
            .attr("viewBox", "0 0 " + svgWidth  + " " + svgHeight );

        let legend = this.root.select(".render-container")
            .append("div")
            .classed("snapshot-legend", true);

         /* add control bar on top for zoom */
        let controller = this.container
        .append("g")
            .attr("id", "controller");

        controller.append("rect")
            .attr("width", width)
            .attr("height", "20px")
            .style("fill", "lightgrey")
            .attr("transform", "translate(10 , 0)")
            .on("click", zoomout);

    
        function zoomout () {
            d3.select("#snap-form").selectAll("input")
            .attr('disabled', null);
            d3.select("#force-container").remove();
            renderer.rerender();
            d3.selectAll(".treeSpecies").filter(d => d.data.id === renderer.zoomId)
                .transition()
                    .duration(750)         
                    .attr("transform", renderer.zoomTransform )           
                .select("rect")
                    .attr("width", d => { return renderer.zoomWidth; })
                    .attr("height", d => { return renderer.zoomHeight; });
            
            renderer.dblclicked = false;

        }
        controller.append("text")
            .attr("dy", "1em")
            .attr("dx", "1em")
            .text("back to root");

            
        let svg = this.svg = container.append('g').attr("id", "snapshot");
        let data = this.layout.snapshot.data;
        data.generateTreeData();
        this.coloring = {};
        this.marking = {};
        this.tooltip = new SnapUIManager(this);

    }

    rerender() {
        d3.selectAll(".treeSpecies").classed("treeSpecies-hidden", false);
        //d3.select(".legend-container").style("opacity", 1);
        this.renderNodes();
    }

    render() {
        this.renderTreeMap();
        this.renderNodes();
        this.tooltip.renderLegend();
    }

    renderTreeMap() {
        let renderer = this;
        let data = this.layout.snapshot.data;
        let width = this.layout.dimension.width;
        let height = this.layout.dimension.height;
        let layout = this.layout;
        let svg = this.svg;
        let treemap = this.treemap = d3.treemap()
            .tile(d3.treemapResquarify)
            .size([width, height - 20])
            .round(true)
            .paddingInner(4);
        let root = this.root = d3.hierarchy(data.treeData)
                .eachBefore(d => { d.data.id = (d.parent ? d.parent.data.id + "." : "") + d.data.name; })
                .sum( d => d.size )
                .sort((a, b) => { return b.height - a.height || b.value - a.value; });

        treemap(root);
     
        let cell = this.cell = this.svg.selectAll(".treeSpecies")
            .data(root.leaves())
            .enter().append("g");

            cell.exit().remove();
        cell
            .merge(cell)
            .attr("class", "treeSpecies")
            .attr("id", d => d.data.id)
            .attr("transform", d => { let x = d.x0 + (layout.margin.left + layout.margin.right)/2;
                                            let y = d.y0 + 30;
                                            return "translate(" + x + "," + y + ")"; });


        cell.append("rect")
                .attr("width", d => { return d.x1 - d.x0; })
                .attr("height", d => { return d.y1 - d.y0; })
                .attr("fill", d => { return "grey"; });

        cell.merge(cell.select("rect"))
                .attr("width", d => { return d.x1 - d.x0; })
                .attr("height", d => { return d.y1 - d.y0; })
                .on("mouseover", mouseoverSpecies)
                .on("mouseout", mouseoutSpecies)
                .on("click", markSpecies)
                .on("dblclick", zoomInSpecies);
            
        function zoomInSpecies (d) 
        {
            d3.select("#snap-form").selectAll("input")
                .attr('disabled', true);
            if (!renderer.dblclicked) {
                d3.selectAll(".treeNodes").transition().duration(200).remove();
                d3.selectAll(".treeSpecies")
                    .classed("treeSpecies-hidden", true)
                .transition().duration(750)
                    .select("rect")
                    .style('pointer-events', 'none');
                    //d3.select(".legend-container").style("opacity", 0);

                let element = d;
                   console.log(element.data.id);
                   
                let zoomDOM = d3.selectAll(".treeSpecies").filter(d => d.data.id === element.data.id).raise();
                    

                zoomDOM
                .classed("treeSpecies-hidden", false)
                    .transition().duration(1000)
                    
                .select("rect")                    
                    .style("fill", "grey")
                    .style("pointer-events", "all");

                renderer.zoomHeight = zoomDOM.select("rect").attr("height");
                renderer.zoomWidth = zoomDOM.select("rect").attr("width");
                renderer.zoomTransform = zoomDOM.attr("transform");

                

                d3.selectAll(".treeSpecies").filter(d => d.data.id === element.data.id)
                .transition()
                    .attr("transform", d => { let x = (layout.margin.left + layout.margin.right)/2;
                                            let y = (layout.margin.top + layout.margin.bottom)/2 + 20;
                                            return "translate(" + x + "," + y + ")"; })
                    .duration(750)                   
                    .select("rect")
                    .attr("width", width )
                    .attr("height", height );
     
                renderer.dblclicked = true;
                renderer.zoomId = element.data.id;
                renderer.renderForceDirected(d.data, d.data.id, height, width);
           
            }
        }
        function mouseoverSpecies(d) {
            let species = d;
            svg.selectAll(".treeRects").filter(d => d.parent.data.name === species.data.name).attr("fill", d => renderer.coloring[d.data.name].darker());
            renderer.tooltip.showSpecies(d);
        }

        function mouseoutSpecies(d) {
            let species = d;
            svg.selectAll(".treeRects").filter(d => d.parent.data.name === species.data.name && renderer.marking[d.parent.data.name] !== 1 ).attr("fill", d => renderer.coloring[d.data.name]);           
            renderer.tooltip.hideSpecies();
        }

        function markSpecies(d) {
            let species = d;
            if (renderer.marking[d.data.name] === undefined) {
                renderer.marking[d.data.name] = 1;
            }
            else if (renderer.marking[d.data.name] === 1) {
                renderer.marking[d.data.name] = 0;
            }
            else {
                renderer.marking[d.data.name] = 1;
            }
            svg.selectAll(".treeRects").filter(d => d.parent.data.name === species.data.name)
                .attr("fill", d => { 
                    if (renderer.marking[d.parent.data.name] === 1 ) {
                        return renderer.coloring[d.data.name].darker();
                    }
                    return renderer.coloring[d.data.name]; 
                });  
            //console.log(renderer.marking);
        }
    }

    renderNodes() {
        let renderer = this;
        let c20 = d3.scaleOrdinal(d3.schemeCategory20);
        let data = this.layout.snapshot.data;
        for (let mixture in data.snapshot) {
            let id = data.snapshot[mixture].id;
            let cell = this.svg.select("#root\\.mixture" + id);
            //console.log(cell.data());

            let width = cell.data()[0].x1 - cell.data()[0].x0;
            let height = cell.data()[0].y1 - cell.data()[0].y0;
            
            // console.log(cell.data()[0], width, height);

            let treemap = this.nodeTreemap = d3.treemap()
                .tile(d3.treemapResquarify)
                .size([width - 4, height - 4])
                .round(true)
                .paddingInner(0);
                
            let tree = data.getSpeciesTree(id);

            //console.log(tree);
            let root = this.nodeRoot = d3.hierarchy(tree)
            .eachBefore(d => { d.data.id = (d.parent ? d.parent.data.id + "." : "") + d.data.name; })
            .sum(d => d.size)
            .sort(function(a, b) { return b.height - a.height || b.value - a.value; });
            
            //console.log(renderer.coloring);
            treemap(root);
            
            let node = this.node = cell.selectAll(".treeNodes")
                .data(root.leaves())
                .enter().append("g")
                    .attr("class", "treeNodes")
                    .attr("id", d => d.data.id)
                    .attr("transform", d => { let x = d.x0 + 2;
                                                     let y = d.y0 + 2;
                                                     return "translate(" + x + "," + y + ")"; });


            node.append("rect")
                    .attr("class", "treeRects")
                    .attr("id", d => d.data.id )
                    .attr("width", d => d.x1 - d.x0 )
                    .attr("height", d => d.y1 - d.y0 )
                    .attr("fill", (d, i) => { 
                        if (renderer.coloring[d.data.name] === undefined) {
                            renderer.coloring[d.data.name] = d3.rgb(c20(Object.keys(renderer.coloring).length));
                        } 
                        if (renderer.marking[d.parent.data.name] === 1)
                            return renderer.coloring[d.data.name].darker();
                        return renderer.coloring[d.data.name]; });
                    //.style('pointer-events', 'none');

            node.exit().remove();
        }
    }

    renderForceDirected(data, id, height, width) {
        /* modified version of mike bostocks force directed graph using d3 */
        let renderer = this;
        let dataLength = data.data.data.length;
        let radius = 4 + 12 / Math.sqrt(dataLength);
        let nodeData = data.data.generateForceDirectedNodes();
        let linkData = data.data.generateForceDirectedLinks();

        let zoom = d3.zoom()
            .scaleExtent([1, 10])
            .translateExtent([[0, 0], [width + 20 , height + 20]])
            .on("zoom", zoomed);

        let forceContainer = d3.selectAll(".treeSpecies").filter(d => d.data.id === id)
            .append("svg").attr("id", "force-container")
            .attr("height", height )
            .attr("width", width )
            .append("g");
            
        
        let zoomRect = d3.selectAll(".treeSpecies").filter(d => d.data.id === id).select("rect");
        zoomRect.call(zoom);
        
        /*add reset button functionality */
        d3.select("#resetButton").on("click", reset);

        function reset() {
            zoomRect.transition().duration(1000)
            .call(zoom.transform, d3.zoomIdentity);
        }
        
        function zoomed() {
            forceContainer.attr("transform", d3.event.transform);
        }
        
        
        let simulation = d3.forceSimulation()
            .force('x', d3.forceX(width/2).strength(0.008))
            .force('y', d3.forceY(height/2).strength(0.008))
            .force("link", d3.forceLink().id( d => d.id ).distance(linkStrength(dataLength)))
            .force("charge", d3.forceManyBody().strength(bodyStrength(dataLength)))
            .force("center", d3.forceCenter(width / 2, height / 2));

        /* function for calculating link strength */
        function linkStrength(n) {
            return 20 + 40/n;
        }
        /* function for reducing strength for large datasets */
        function bodyStrength(n) {
            return -3 - 30/Math.sqrt(n); 
        }

        let link = forceContainer.append("g")
            .attr("class", "snapshot-links")
            .selectAll("line")
            .data(linkData)
            .enter().append("line")
            .attr("stroke-width", d => Math.sqrt(d.value) );

        let node = forceContainer.append("g")
            .attr("class", "nodes")
            .selectAll("circle")
            .data(nodeData)
            .enter().append("circle")
            .attr("r", radius)
            .attr("fill", d => renderer.coloring[d.label] )
            .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));

        node.append("title")
            .text(function(d) { return d.id; });

        simulation
            .nodes(nodeData)
            .on("tick", ticked);

        simulation.force("link")
            .links(linkData);

        function ticked() {
                link
                    .attr("x1", d => d.source.x )
                    .attr("y1",  d => d.source.y )
                    .attr("x2",  d => d.target.x )
                    .attr("y2", d => d.target.y );

                node.attr("cx", d => d.x = Math.max(radius, Math.min(width - radius - 2, d.x)) )
                    .attr("cy", d => d.y = Math.max(radius, Math.min(height - radius - 10, d.y)) );
            }

        function dragstarted(d) {
            if (!d3.event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        }

        function dragged(d) {
            d.fx = d3.event.x;
            d.fy = d3.event.y;
        }

        function dragended(d) {
            if (!d3.event.active) simulation.alphaTarget(0);
            d.fx = null;
            d.fy = null;
        }
    }

    removeNodes() {
        d3.selectAll(".treeNodes").remove();
    }

}