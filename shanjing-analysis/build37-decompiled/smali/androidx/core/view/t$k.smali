.class Landroidx/core/view/t$k;
.super Landroidx/core/view/t$j;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Landroidx/core/view/t;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "k"
.end annotation


# static fields
.field static final q:Landroidx/core/view/t;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    sget-object v0, Landroid/view/WindowInsets;->CONSUMED:Landroid/view/WindowInsets;

    invoke-static {v0}, Landroidx/core/view/t;->n(Landroid/view/WindowInsets;)Landroidx/core/view/t;

    move-result-object v0

    sput-object v0, Landroidx/core/view/t$k;->q:Landroidx/core/view/t;

    return-void
.end method

.method constructor <init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Landroidx/core/view/t$j;-><init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V

    return-void
.end method

.method constructor <init>(Landroidx/core/view/t;Landroidx/core/view/t$k;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Landroidx/core/view/t$j;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$j;)V

    return-void
.end method


# virtual methods
.method final d(Landroid/view/View;)V
    .locals 0

    return-void
.end method

.method public g(I)Landroidx/core/graphics/a;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$g;->c:Landroid/view/WindowInsets;

    invoke-static {p1}, Landroidx/core/view/t$n;->a(I)I

    move-result p1

    invoke-static {v0, p1}, Landroidx/core/view/a0;->a(Landroid/view/WindowInsets;I)Landroid/graphics/Insets;

    move-result-object p1

    invoke-static {p1}, Landroidx/core/graphics/a;->d(Landroid/graphics/Insets;)Landroidx/core/graphics/a;

    move-result-object p1

    return-object p1
.end method

.method public o(I)Z
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$g;->c:Landroid/view/WindowInsets;

    invoke-static {p1}, Landroidx/core/view/t$n;->a(I)I

    move-result p1

    invoke-static {v0, p1}, Landroidx/core/view/z;->a(Landroid/view/WindowInsets;I)Z

    move-result p1

    return p1
.end method
